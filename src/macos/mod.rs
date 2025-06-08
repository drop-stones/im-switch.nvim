mod args;
pub mod error;
pub mod input_method;

use crate::macos::error::MacOsError;
use args::Args;
use clap::Parser;
use input_method::*;

pub fn run() -> Result<(), MacOsError> {
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
