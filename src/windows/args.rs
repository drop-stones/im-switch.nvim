use clap::{Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
pub struct Args {
  #[command(subcommand)]
  pub command: Command,
}

#[derive(Subcommand, Debug)]
pub enum Command {
  /// Activate input method
  Enable,
  /// Inactivate input method
  Disable,
  /// Get current input method ("on" or "off")
  Get,
}
