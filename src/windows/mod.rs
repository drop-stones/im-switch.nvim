mod args;
pub mod im;

use args::Args;
use clap::{CommandFactory, Parser};
use im::*;
use std::error::Error;

pub fn run() -> Result<(), Box<dyn Error>> {
  let args: Args = Args::parse();

  if args.activate {
    activate_im()?;
  } else if args.inactivate {
    inactivate_im()?;
  } else if args.get {
    println!("{}", get_input_method()?);
  } else {
    let mut cmd = Args::command();
    cmd.print_help()?;
  }

  Ok(())
}
