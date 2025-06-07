mod args;
pub mod input_method;

use args::Args;
use clap::Parser;
use input_method::*;
use std::error::Error;

pub fn run() -> Result<(), Box<dyn Error>> {
  let args: Args = Args::parse();

  match args.command {
    args::Command::Set { input_method } => {
      set_input_method(&input_method)?;
    }
    args::Command::Get => {
      println!("{}", get_input_method()?);
    }
  }
  Ok(())
}
