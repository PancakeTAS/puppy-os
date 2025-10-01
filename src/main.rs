use std::env;

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
    /// Package to build
    #[arg(index = 1)]
    pub pkg: String
}

fn main() {
    let config = Configuration::parse();

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
