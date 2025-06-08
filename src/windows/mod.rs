mod args;
pub mod error;
pub mod input_method;

use crate::windows::error::WindowsError;
use args::Args;
use clap::Parser;
use input_method::*;

pub fn run() -> Result<(), WindowsError> {
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
