mod args;
mod im;

use args::Args;
use clap::{CommandFactory, Parser};
use im::*;

pub fn run() {
    let args: Args = Args::parse();

    if let Some(im) = args.set.as_deref() {
        unsafe { set_input_method(im) };
    } else if args.get {
        unsafe { println!("{}", get_input_method()) };
    } else {
        let mut cmd = Args::command();
        cmd.print_help().unwrap();
    }
}

// Tests
#[cfg(test)]
mod test {
    use super::*;
    use clap::CommandFactory;

    #[test]
    fn test_args() {
        Args::command().debug_assert()
    }
}
