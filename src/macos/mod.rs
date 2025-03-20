mod args;
pub mod input_method;

use args::Args;
use clap::{CommandFactory, Parser};
use input_method::*;
use std::error::Error;

pub fn run() -> Result<(), Box<dyn Error>> {
  let args: Args = Args::parse();

  if let Some(input_method) = args.set.as_deref() {
    set_input_method(input_method)?;
  } else if args.get {
    println!("{}", get_input_method()?);
  } else {
    let mut cmd = Args::command();
    cmd.print_help()?;
  }
  Ok(())
}
