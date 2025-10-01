use std::{fs, os::unix, path::{Path, PathBuf}};

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
        if !dir.exists() {
            anyhow::bail!("Build directory does not exist");
        }

        // turn dir into absolute path
        let mut dir = dir.to_path_buf();
        if !dir.is_absolute() {
            dir = std::env::current_dir()?.join(dir);
        }

        // create timed subdirectory
        let rand = rand::random::<u32>();
        let dir = dir.join(format!("{}", rand));
        fs::create_dir(&dir)?;

        // create subdirectories
        let tempdir = dir.join("temp");
        let pkgroot = dir.join("pkgroot");
        let buildroot = dir.join("buildroot");
        fs::create_dir(&tempdir)?;
        fs::create_dir(&pkgroot)?;
        fs::create_dir(&buildroot)?;

        // prepare buildroot
        fs::create_dir(buildroot.join("usr"))?;
        fs::create_dir(buildroot.join("usr/include"))?;
        fs::create_dir(buildroot.join("usr/share"))?;
        fs::create_dir(buildroot.join("usr/lib"))?;
        fs::create_dir(buildroot.join("usr/bin"))?;
        unix::fs::symlink("usr/bin", buildroot.join("bin"))?;
        unix::fs::symlink("usr/bin", buildroot.join("sbin"))?;
        unix::fs::symlink("usr/lib", buildroot.join("lib"))?;
        unix::fs::symlink("usr/lib", buildroot.join("libexec"))?;
        unix::fs::symlink("usr/lib", buildroot.join("lib64"))?;
        unix::fs::symlink("bin", buildroot.join("usr/sbin"))?;
        unix::fs::symlink("lib", buildroot.join("usr/lib64"))?;

        Ok(Self { tempdir, pkgroot, buildroot })
    }
}

impl Drop for Environment {
    /// Clean up temporary directories
    fn drop(&mut self) {
        if self.tempdir.exists() {
            let parent = self.tempdir.parent().unwrap();
            fs::remove_dir_all(&parent)
                .expect("Failed to remove build directory");
        }
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
        .arg(&src)
        .arg(".")
        .output()
        .context("Failed to create tarball")?;
    if !output.status.success() {
        anyhow::bail!("Failed to create tarball (status {})", output.status);
    }
    Ok(output.stdout)
}
