use std::{fs, io::{BufRead, BufReader}, os::unix, path::{Path, PathBuf}, process::{ChildStderr, ChildStdout}, sync::{self, mpsc::Receiver}, thread, time::Instant};

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

        prepare_sysroot(&buildroot)?;

        Ok(Self { tempdir, pkgroot, buildroot })
    }
}

impl Drop for Environment {
    /// Clean up temporary directories
    fn drop(&mut self) {
        if self.tempdir.exists() {
            let parent = self.tempdir.parent()
                .expect("Found lonely filesystem node");
            fs::remove_dir_all(&parent)
                .expect("Failed to remove build directory");
        }
    }
}

/// Extract a tarball to a destination
pub fn extract_tar(tarball: &Path, dest: &Path) -> anyhow::Result<()> {
    let status = std::process::Command::new("tar") // tar-rs is *somehow* broken
        .arg("xhf")
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

/// Route a command's stdout and stderr to the channels
pub fn route_command(stdout: ChildStdout, stderr: ChildStderr) -> Receiver<String> {
    let (tx, rx) = sync::mpsc::channel();

    let tx_stdout = tx.clone();
    thread::spawn(move || {
        let reader = BufReader::new(stdout);
        for line in reader.lines() {
            if let Ok(line) = line {
                let _ = tx_stdout.send(line);
            }
        }
    });

    let tx_stderr = tx.clone();
    thread::spawn(move || {
        let reader = BufReader::new(stderr);
        for line in reader.lines() {
            if let Ok(line) = line {
                let _ = tx_stderr.send(line);
            }
        }
    });

    rx
}


/// State of a package
pub enum PkgState {
    Pending,
    InProgress(Instant), // start time
    Cached,
    Built(u64) // duration
}

/// Format a tree entry
pub fn fmt_entry(name: &str, state: &PkgState) -> String {
    let emoji_str = match state {
        PkgState::Pending => "\x1b[36m\u{16ED}",
        PkgState::InProgress(_) => "\x1b[1;33m\u{23F5}",
        PkgState::Cached => "\x1b[0;32m\u{2713}",
        PkgState::Built(_) => "\x1b[0;32m\u{2713}"
    };
    let suffix_str = match state {
        PkgState::Pending => "".to_string(),
        PkgState::InProgress(start) => {
            let elapsed = start.elapsed().as_secs();
            format!("\x1b[0;37m (building for {}s)", elapsed)
        },
        PkgState::Cached => "\x1b[0;37m".to_string(),
        PkgState::Built(duration) => format!("\x1b[0;37m ({}s)", duration)
    };
    format!("{} {}{}\x1b[0m", emoji_str, name, suffix_str)
}

fn prepare_sysroot(root: &Path) -> anyhow::Result<()> {
    fs::create_dir(root.join("usr"))?;
    fs::create_dir(root.join("usr/include"))?;
    fs::create_dir(root.join("usr/share"))?;
    fs::create_dir(root.join("usr/lib"))?;
    fs::create_dir(root.join("usr/bin"))?;
    unix::fs::symlink("usr/bin", root.join("bin"))?;
    unix::fs::symlink("usr/bin", root.join("sbin"))?;
    unix::fs::symlink("usr/lib", root.join("lib"))?;
    unix::fs::symlink("usr/lib", root.join("libexec"))?;
    unix::fs::symlink("usr/lib", root.join("lib64"))?;
    unix::fs::symlink("bin", root.join("usr/sbin"))?;
    unix::fs::symlink("lib", root.join("usr/lib64"))?;
    Ok(())
}

/// Create a sysroot from a list of tarballs
pub fn make_sysroot(sysroot: &Path, pkgs: &Vec<PathBuf>) -> anyhow::Result<()> {
    if sysroot.exists() {
        anyhow::bail!("Directory for sysroot already exists.");
    }

    fs::create_dir(sysroot)
        .context("Failed to create sysroot directory")?;
    prepare_sysroot(sysroot)
        .context("Failed to prepare sysroot directory")?;

    for pkg in pkgs {
        extract_tar(pkg, sysroot)
            .with_context(|| format!("Failed to extract package {:?}", pkg))?;
    }

    Ok(())
}
