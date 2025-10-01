use clap::Parser;

pub mod output;
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
    let mut state = state::State::new(config)
        .expect("Unable to initialize state");
    let pkg = state.get_pkg()
        .expect("Unable to get package");
    let mut output = output::Output::new(&state.repo, pkg, &state.cache);
    state.build_pkg(None, &mut output)
        .expect("Unable to build package");
}
