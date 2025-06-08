use clap::{Parser, Subcommand};

/// Command-line arguments for the macOS input method switcher.
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
pub struct Args {
  /// The subcommand to execute.
  #[command(subcommand)]
  pub command: Command,
}

#[derive(Subcommand, Debug)]
pub enum Command {
  /// Get the current input method
  Get,
  /// Set the input method
  Set {
    /// Input method to set
    input_method: String,
  },
}
