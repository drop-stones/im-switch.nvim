mod args;
pub mod input_method;

use args::Args;
use clap::{CommandFactory, Parser};
use input_method::*;
use std::error::Error;

pub fn run() -> Result<(), Box<dyn Error>> {
  let args: Args = Args::parse();

  if args.enable {
    enable_im()?;
  } else if args.disable {
    disable_im()?;
  } else if args.get {
    println!("{}", get_im_state()?);
  } else {
    let mut cmd = Args::command();
    cmd.print_help()?;
  }

  Ok(())
}
