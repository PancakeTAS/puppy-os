use clap::Parser;

pub mod utils;
pub mod state;

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
    let mut state = state::State::new(config)
        .expect("Unable to initialize state");
    state.build_pkg(None)
        .expect("Unable to build package");
}
