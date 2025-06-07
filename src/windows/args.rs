use clap::{Parser, Subcommand};

/// Command-line arguments for the Windows input method switcher.
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
pub struct Args {
  /// The subcommand to execute.
  #[command(subcommand)]
  pub command: Command,
}

/// Supported subcommands for input method control.
#[derive(Subcommand, Debug)]
pub enum Command {
  /// Activate the input method.
  Enable,
  /// Deactivate the input method.
  Disable,
  /// Get the current input method state ("on" or "off").
  Get,
}
