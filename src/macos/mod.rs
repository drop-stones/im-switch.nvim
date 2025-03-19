mod args;
mod im;

use args::Args;
use clap::{CommandFactory, Parser};
use im::*;
use std::error::Error;

pub fn run() -> Result<(), Box<dyn Error>> {
  let args: Args = Args::parse();

  if let Some(im) = args.set.as_deref() {
    set_input_method(im)?;
  } else if args.get {
    println!("{}", get_input_method()?);
  } else {
    let mut cmd = Args::command();
    cmd.print_help()?;
  }
  Ok(())
}
