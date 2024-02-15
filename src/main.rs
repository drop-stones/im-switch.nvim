use clap::{CommandFactory, Parser};

// Windows
#[cfg(target_os = "windows")]
mod windows;
#[cfg(target_os = "windows")]
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
#[group(multiple = false)]
struct Args {
    /// Activate input method
    #[arg(short, long)]
    activate: bool,

    /// Inactivate input method
    #[arg(short, long)]
    inactivate: bool,

    /// Get current input method ("on" or "off")
    #[arg(short, long)]
    get: bool,
}

#[cfg(target_os = "windows")]
fn main() {
    use crate::windows::im::{activate_im, get_input_method, inactivate_im};

    let args: Args = Args::parse();

    if args.activate {
        unsafe { activate_im() };
    } else if args.inactivate {
        unsafe { inactivate_im() };
    } else if args.get {
        unsafe { println!("{}", get_input_method()) };
    } else {
        let mut cmd = Args::command();
        cmd.print_help().unwrap();
    }
}

// macos
#[cfg(target_os = "macos")]
mod macos;
#[cfg(target_os = "macos")]
use macos::im::*;
#[cfg(target_os = "macos")]
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
#[group(multiple = false)]
struct Args {
    /// Set input method
    #[arg(short, long)]
    set: Option<String>,

    /// Get current input method
    #[arg(short, long)]
    get: bool,
}

#[cfg(target_os = "macos")]
fn main() {
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
#[cfg(target_os = "windows")]
#[cfg(test)]
mod test {
    use super::*;
    use clap::CommandFactory;

    #[test]
    fn test_args() {
        Args::command().debug_assert()
    }
}

#[cfg(target_os = "macos")]
#[cfg(test)]
mod test {
    use super::*;
    use clap::CommandFactory;

    #[test]
    fn test_args() {
        Args::command().debug_assert()
    }
}
