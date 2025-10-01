use std::{collections::HashMap, rc::Rc, time::Instant};

use console::Term;
use ptree::TreeBuilder;

use crate::state::{cache, pkg, repo};

pub struct Output {
    terminal: Term,
    postlines: usize,
    states: HashMap<String, State>,
    root: Rc<pkg::Package>
}

impl Output {
    /// Recursively build a tree
    fn build_tree(&self, builder: &mut TreeBuilder, repo: &repo::Repository, pkg: &pkg::Package) {
        let name = &pkg.metadata.name;
        let state = self.states.get(name).unwrap_or(&State::Pending);
        let entry = fmt_entry(&pkg.metadata.name, state);

        let mut node = builder.begin_child(entry);
        for (name, version) in &pkg.dependencies {
            let dep = repo.find_pkg(name, Some(version)).unwrap();
            self.build_tree(&mut node, repo, &dep);
        }
        node.end_child();
    }
    /// Build a full tree as string
    fn make_tree(&self, repo: &repo::Repository, pkg: &pkg::Package) -> String {
        let mut builder = TreeBuilder::new("=== Dependency Graph ===".to_string());
        self.build_tree(&mut builder, repo, pkg);
        let tree = builder.build();

        let mut bytes = Vec::new();
        ptree::write_tree(&tree, &mut bytes).unwrap();
        String::from_utf8(bytes).unwrap()
    }
}

impl Output {
    /// Create a new output handler
    pub fn new(repo: &repo::Repository, pkg: Rc<pkg::Package>, cache: &cache::Cache) -> Self {
        let states = cache.get_pkgs().keys().
            map(|k| (k.clone(), State::Cached)).
            collect();
        let mut output = Output {
            terminal: Term::stdout(),
            postlines: 0,
            states,
            root: pkg.clone()
        };

        let tree = output.make_tree(repo, &output.root);
        output.postlines = tree.matches('\n').count() + 1;
        output.terminal.write_line(&tree).unwrap();

        output
    }
    /// Append a line above the tree
    pub fn append_line(&mut self, line: &str, repo: &repo::Repository) {
        self.terminal.clear_last_lines(self.postlines).unwrap();
        self.terminal.write_line(line).unwrap();
        self.print_tree(repo);
    }
    /// Update the tree
    pub fn print_tree(&mut self, repo: &repo::Repository) {
        let tree = self.make_tree(repo, &self.root);
        self.terminal.write_line(&tree).unwrap();
    }
    /// Mark a package as in progress
    pub fn mark_in_progress(&mut self, name: &str) {
        self.states.insert(name.to_string(), State::InProgress(Instant::now()));
    }
    /// Mark a package as built
    pub fn mark_built(&mut self, name: &str, duration: u64) {
        self.states.remove(name);
        self.states.insert(name.to_string(), State::Built(duration));
    }
}

/// State of a package
enum State {
    Pending,
    InProgress(Instant), // start time
    Cached,
    Built(u64) // duration
}

/// Format a tree entry
fn fmt_entry(name: &str, state: &State) -> String {
    let emoji_str = match state {
        State::Pending => "\x1b[36m\u{16ED}",
        State::InProgress(_) => "\x1b[1;33m\u{23F5}",
        State::Cached => "\x1b[0;32m\u{2713}",
        State::Built(_) => "\x1b[0;32m\u{2713}"
    };
    let suffix_str = match state {
        State::Pending => "".to_string(),
        State::InProgress(start) => {
            let elapsed = start.elapsed().as_secs();
            format!("\x1b[0;37m (building for {}s)", elapsed)
        },
        State::Cached => "\x1b[0;37m".to_string(),
        State::Built(duration) => format!("\x1b[0;37m ({}s)", duration)
    };
    format!("{} {}{}\x1b[0m", emoji_str, name, suffix_str)
}
