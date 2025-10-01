use std::{fs, path::Path, process::Command};

use anyhow::{bail, Context};

use crate::utils;

pub mod pkg {
    use serde::Deserialize;
    use std::{collections::HashMap, fs, path::Path};

    /// Package Metadata
    #[derive(Debug, Clone, Deserialize)]
    pub struct Metadata {
        pub name: String,
        pub version: String,
        pub release: u32,
        pub description: String,
        pub url: String,
        pub license: String,
    }
    /// Versioned Dependency Map
    pub type DependencyMap = HashMap<String, String>;
    /// Folder-to-URL Source Map
    pub type SourceMap = HashMap<String, String>;
    /// Build Information
    #[derive(Debug, Clone, Deserialize)]
    pub struct Build {
        pub script: String,
    }

    /// A simple representation of a software package
    #[derive(Debug, Clone, Deserialize)]
    pub struct Package {
        pub metadata: Metadata,
        pub dependencies: DependencyMap,
        pub sources: SourceMap,
        pub build: Build,
    }

    impl Package {
        /// Parse a package from a TOML file
        pub fn from_toml_file(toml_file: &Path) -> anyhow::Result<Self> {
            let content = fs::read_to_string(toml_file)?;
            let pkg = toml::from_str::<Package>(&content)?;
            Ok(pkg)
        }
    }
}

pub mod repo {
    use std::{fs, path::Path, rc::Rc};
    use anyhow::Context;
    use crate::state::pkg;

    /// Package repository
    pub struct Repository {
        pkgs: Vec<Rc<pkg::Package>>,
    }

    impl Repository {
        /// List all packages in a directory
        fn fetch_pkgs(pkgdir: &Path) -> anyhow::Result<Vec<pkg::Package>> {
            fs::read_dir(pkgdir)?
                .filter_map(Result::ok)
                .map(|entry| {
                    pkg::Package::from_toml_file(&entry.path())
                        .with_context(|| format!("Unable to parse package in {:?}", entry.file_name()))
                })
                .collect()
        }
        /// Resolve dependencies for a package (WILL break on circular deps)
        fn resolve_deps2(&self, deps: &mut Vec<Rc<pkg::Package>>, pkg: &pkg::Package) -> anyhow::Result<()> {
            for (name, ver) in &pkg.dependencies {
                let dep = self.find_pkg(name, Some(ver))
                    .with_context(|| format!("Unable to find dependency {}-{}", name, ver))?;

                self.resolve_deps2(deps, &dep)?;

                if deps.iter()
                        .find(|p| p.metadata.name == dep.metadata.name)
                        .is_none() {
                    deps.push(dep);
                }
            }

            Ok(())
        }
    }

    impl Repository {
        /// Create a new repository from a directory
        pub fn new(pkgdir: &Path) -> anyhow::Result<Self> {
            let pkgs = Self::fetch_pkgs(pkgdir)?.into_iter()
                .map(Rc::new)
                .collect();
            Ok(Self { pkgs })
        }
        /// Find a package by name
        pub fn find_pkg(&self, name: &str, version: Option<&str>) -> Option<Rc<pkg::Package>> {
            self.pkgs.iter()
                .find(|p|
                    p.metadata.name.eq(name) &&
                    p.metadata.version.eq(version.unwrap_or(&p.metadata.version)))
                .cloned()
        }
        /// Resolve dependencies for a package
        pub fn resolve_deps(&self, pkg: &pkg::Package) -> anyhow::Result<Vec<Rc<pkg::Package>>> {
            let mut deps = Vec::new();
            self.resolve_deps2(&mut deps, pkg)?;
            Ok(deps)
        }
    }
}

pub mod cache {
    use std::{fs, path::{Path, PathBuf}};
    use anyhow::{bail, Context};
    use crate::state::pkg;

    /// Build cache
    pub struct Cache {
        srcdir: PathBuf,
        sources: pkg::SourceMap,
        pkgdir: PathBuf,
        pkgs: pkg::DependencyMap,
        client: reqwest::blocking::Client,
    }

    impl Cache {
        /// Create a new cache in the specified directory
        pub fn new(dir: &Path) -> anyhow::Result<Self> {
            let srcdir = dir.join("src");
            let pkgdir = dir.join("pkgs");
            std::fs::create_dir_all(&srcdir)
                .context("Failed to create cache directory")?;
            std::fs::create_dir_all(&pkgdir)
                .context("Failed to create package cache directory")?;

            let mut sources = pkg::SourceMap::new();
            for entry in fs::read_dir(&srcdir)? {
                let entry = entry?;
                let name = entry.file_name();
                let name = name.to_string_lossy();
                if !name.ends_with(".url") {
                    continue;
                }

                let base = &name[..name.len() - 4];
                if !fs::exists(srcdir.join(base))? {
                    continue;
                }

                let url = fs::read_to_string(entry.path())
                    .with_context(|| format!("Failed to read cache entry: {}", entry.path().display()))?;
                sources.insert(base.to_string(), url.trim().to_string());
            }

            let mut pkgs = pkg::DependencyMap::new();
            for entry in fs::read_dir(&pkgdir)? {
                let entry = entry?;
                let name = entry.file_name();
                let name = name.to_string_lossy();
                if !name.ends_with(".ver") {
                    continue;
                }

                let base = &name[..name.len() - 4];
                if !fs::exists(pkgdir.join(base))? {
                    continue;
                }

                let ver = fs::read_to_string(entry.path())
                    .with_context(|| format!("Failed to read cache entry: {}", entry.path().display()))?;
                pkgs.insert(base.to_string(), ver.trim().to_string());
            }

            let client = reqwest::blocking::Client::builder()
                .timeout(std::time::Duration::from_secs(600))
                .build()?;

            Ok(Self { srcdir, pkgdir, sources, pkgs, client })
        }
        /// Fetch a resource from the cache or download it if not present
        pub fn fetch_source(&mut self, url: &str) -> anyhow::Result<PathBuf> {
            // get basename from url
            let basename = url.split('/').last()
                .ok_or_else(|| anyhow::anyhow!("Invalid URL: {}", url))?;

            // check cache first
            if let Some(cached_url) = self.sources.get(basename) {
                if cached_url == url {
                    return Ok(self.srcdir.join(basename));
                }
            }

            // download resource
            let response = self.client.get(url).send()
                .context("Failed to download resource from")?;
            if !response.status().is_success() {
                bail!("Failed to download resource (HTTP {})", response.status());
            }

            let content = response.bytes()
                .context("Failed to read response body")?;

            let path = self.srcdir.join(basename);
            fs::write(&path, &content)
                .context("Failed to write resource")?;

            let url_path = self.srcdir.join(format!("{}.url", basename));
            fs::write(&url_path, url)
                .context("Failed to write URL file")?;

            self.sources.insert(basename.to_string(), url.to_string());

            Ok(path)
        }
        /// Try to fetch a built package from the cache
        pub fn fetch_pkg(&self, name: &str, version: &str) -> Option<PathBuf> {
            self.pkgs.get(name)
                .filter(|v| *v == version)
                .map(|_| self.pkgdir.join(name))
        }
        /// Store a built package in the cache
        pub fn store_pkg(&mut self, name: &str, version: &str, data: &[u8]) -> anyhow::Result<()> {
            let path = self.pkgdir.join(name);
            fs::write(&path, data)
                .context("Failed to write package data")?;

            let ver_path = self.pkgdir.join(format!("{}.ver", name));
            fs::write(&ver_path, version)
                .context("Failed to write version file")?;

            self.pkgs.insert(name.to_string(), version.to_string());

            Ok(())
        }
    }
}

/// Global state of the build system
pub struct State {
    cfg: crate::Configuration,
    repo: repo::Repository,
    cache: cache::Cache,
}

impl State {
    /// Create a new state from a configuration
    pub fn new(cfg: crate::Configuration) -> anyhow::Result<Self> {
        let repo = repo::Repository::new(Path::new(&cfg.pkgdir))
            .context("Failed to fetch packages")?;
        let cache = cache::Cache::new(Path::new(&cfg.cachedir))
            .context("Failed to create cache")?;

        Ok(Self { cfg, repo, cache })
    }
    /// Build a package by name
    pub fn build_pkg(&mut self, name: Option<&str>) -> anyhow::Result<()> {
        let name = name.unwrap_or(&self.cfg.pkg);
        let pkg = self.repo.find_pkg(name, None)
            .context("Failed to find package")?;
        let env = utils::Environment::new(Path::new(&self.cfg.builddir))
            .context("Failed to create build environment")?;

        // build and extract dependencies
        for dep in &pkg.dependencies {
            let mut path = self.cache.fetch_pkg(dep.0, dep.1);
            if path.is_none() {
                self.build_pkg(Some(dep.0))?;
                path = self.cache.fetch_pkg(dep.0, dep.1);
            }
            let path = path.unwrap();
            utils::extract_tar(&path, &env.buildroot)
                .with_context(|| format!("Failed to extract dependency: {}", path.display()))?;
        }

        // download and extract sources
        for src in &pkg.sources {
            let path = self.cache.fetch_source(&src.1)
                .with_context(|| format!("Failed to fetch source: {}", src.1))?;
            utils::extract_tar(&path, &env.tempdir)
                .with_context(|| format!("Failed to extract source: {}", path.display()))?;
        }

        // run build script
        let script_path = env.tempdir.join("build.sh");
        fs::write(&script_path, pkg.build.script.as_bytes())
            .context("Failed to write build script")?;

        let status = Command::new("sh")
            .arg("-euo")
            .arg("pipefail")
            .arg(&script_path.canonicalize()?)
            .env("pkgroot", &env.pkgroot.canonicalize()?)
            .env("buildroot", &env.buildroot.canonicalize()?)
            .current_dir(&env.tempdir)
            .status()
            .context("Failed to execute build script")?;
        if !status.success() {
            bail!("Build script failed with status: {}", status);
        }

        // create package archive
        let tarball = utils::make_tar(&env.pkgroot)
            .context("Failed to create package archive")?;
        self.cache.store_pkg(&pkg.metadata.name, &pkg.metadata.version, &tarball)
            .context("Failed to store package in cache")?;
        Ok(())
    }
}
