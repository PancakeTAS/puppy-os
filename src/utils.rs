use std::{fs, os::unix, path::{Path, PathBuf}, time};

use anyhow::Context;

/// Build environment
#[derive(Debug)]
pub struct Environment {
    pub tempdir: PathBuf,
    pub pkgroot: PathBuf,
    pub buildroot: PathBuf
}

impl Environment {
    /// Create a new environment
    pub fn new(dir: &Path) -> anyhow::Result<Self> {
        let timestamp = time::SystemTime::now()
            .duration_since(time::UNIX_EPOCH)
            .expect("Time went backwards")
            .as_secs();

        let tempdir = dir.join(format!("build-{}", timestamp));
        let pkgroot = dir.join(format!("pkg-{}", timestamp));
        let buildroot = dir.join(format!("buildroot-{}", timestamp));
        fs::create_dir_all(&tempdir)
            .with_context(|| format!("Failed to create tempdir at {}", tempdir.display()))?;
        fs::create_dir_all(&pkgroot)
            .with_context(|| format!("Failed to create pkgroot at {}", pkgroot.display()))?;
        fs::create_dir_all(&buildroot)
            .with_context(|| format!("Failed to create buildroot at {}", buildroot.display()))?;

        fs::create_dir_all(buildroot.join("usr/include"))?;
        fs::create_dir_all(buildroot.join("usr/lib"))?;
        fs::create_dir_all(buildroot.join("usr/libexec"))?;
        fs::create_dir_all(buildroot.join("usr/bin"))?;
        unix::fs::symlink(PathBuf::from("usr/bin"), buildroot.join("bin"))?;
        unix::fs::symlink(PathBuf::from("usr/bin"), buildroot.join("sbin"))?;
        unix::fs::symlink(PathBuf::from("usr/lib"), buildroot.join("lib"))?;
        unix::fs::symlink(PathBuf::from("usr/lib"), buildroot.join("libexec"))?;
        unix::fs::symlink(PathBuf::from("usr/lib"), buildroot.join("lib64"))?;
        unix::fs::symlink(PathBuf::from("bin"), buildroot.join("usr/sbin"))?;
        unix::fs::symlink(PathBuf::from("lib"), buildroot.join("usr/lib64"))?;

        unix::fs::symlink(buildroot.canonicalize()?, PathBuf::from("/tmp/dog-buildroot"))?;

        Ok(Self {
            tempdir,
            pkgroot,
            buildroot,
        })
    }
}

impl Drop for Environment {
    /// Clean up temporary directories
    fn drop(&mut self) {
        if self.tempdir.exists() {
            fs::remove_dir_all(&self.tempdir)
                .expect("Failed to remove temporary build directory");
        }
        if self.pkgroot.exists() {
            fs::remove_dir_all(&self.pkgroot)
                .expect("Failed to remove package directory");
        }
        if self.buildroot.exists() {
            fs::remove_dir_all(&self.buildroot)
                .expect("Failed to remove buildroot directory");
        }

        fs::remove_file("/tmp/dog-buildroot")
            .expect("Failed to remove buildroot symlink");
    }
}

/// Extract a tarball to a destination
pub fn extract_tar(tarball: &Path, dest: &Path) -> anyhow::Result<()> {
    let status = std::process::Command::new("tar") // tar-rs is *somehow* broken
        .arg("xf")
        .arg(tarball.canonicalize()?)
        .arg("-C")
        .arg(dest.canonicalize()?)
        .status()
        .context("Failed to extract tarball")?;
    if !status.success() {
        anyhow::bail!("Failed to extract tarball (status {})", status);
    }
    Ok(())
}

/// Make a tarball from a directory
pub fn make_tar(src: &Path) -> anyhow::Result<Vec<u8>> {
    let output = std::process::Command::new("tar")
        .arg("cJf")
        .arg("-")
        .arg("-C")
        .arg(src.canonicalize()?)
        .arg(".")
        .output()
        .context("Failed to create tarball")?;
    if !output.status.success() {
        anyhow::bail!("Failed to create tarball (status {})", output.status);
    }
    Ok(output.stdout)
}
