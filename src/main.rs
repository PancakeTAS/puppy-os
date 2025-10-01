use std::{env, path::PathBuf};

use anyhow::Context;
use clap::Parser;

pub mod state;
pub mod utils;

#[derive(Parser)]
#[command(about)]
pub struct Configuration {
    /// Directory containing package recipes
    #[arg(short, long, default_value = "pkgs")]
    pub pkgdir: String,
    /// Download and package cache directory
    #[arg(short, long, default_value = "cache")]
    pub cachedir: String,
    /// Temporary build directory (tmpfs recommended)
    #[arg(short, long, default_value = "build")]
    pub builddir: String,
    /// Build a sysroot from packages (comma-separated)
    #[arg(short, long)]
    pub sysroot: Option<String>,
    /// Package to build
    #[arg(index = 1)]
    pub pkg: String
}

fn main() {
    let config = Configuration::parse();
    if config.sysroot.is_some() {
        let cache = state::cache::Cache::new(&PathBuf::from(config.cachedir))
            .expect("An error occurred while initializing the cache");
        let pkgs = config.pkg.split(',')
            .map(|s| s.to_string())
            .collect::<Vec<String>>();
        let paths = pkgs.iter()
            .map(|p| cache.fetch_pkg(p, None)
                .with_context(|| format!("Package {} not found in cache.", p)))
            .collect::<Result<Vec<PathBuf>, _>>()
            .expect("An error occurred while fetching packages from cache");

        utils::make_sysroot(&PathBuf::from("sysroot"), &paths)
            .expect("An error occurred while creating the sysroot");

        return;
    }

    // set environment variables
    unsafe {
        let cwd = std::env::current_dir()
            .expect("Unable to get current directory");

        let mut prefix = cwd.to_path_buf().join("toolchain/bin").to_str().unwrap().to_string();
        prefix.push(':');
        prefix.push_str(&env::var("PATH").unwrap());

        println!("Using tools from {}/toolchain/bin", cwd.to_str().unwrap());

        env::set_var("PATH", prefix);
    }

    unsafe {
        let nproc = num_cpus::get();

        println!("Using {} parallel jobs", nproc);

        let flags = format!("-j{}", nproc);
        env::set_var("MAKEFLAGS", flags);
    }

    // create state
    let mut state = state::State::new(config)
        .expect("An error occurred while initializing the state");

    state.build_pkg(None)
        .expect("An error occurred during the build");
}
