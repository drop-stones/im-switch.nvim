mod args;
pub mod input_method;

use args::Args;
use clap::Parser;
use input_method::*;
use std::error::Error;

pub fn run() -> Result<(), Box<dyn Error>> {
  let args: Args = Args::parse();

  match args.command {
    args::Command::Enable => {
      enable_im()?;
    }
    args::Command::Disable => {
      disable_im()?;
    }
    args::Command::Get => {
      println!("{}", get_im_state()?);
    }
  }
  Ok(())
}
