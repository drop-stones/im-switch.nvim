use clap::Parser;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
#[group(multiple = false)]
pub struct Args {
  /// Activate input method
  #[arg(short, long)]
  pub enable: bool,

  /// Inactivate input method
  #[arg(short, long)]
  pub disable: bool,

  /// Get current input method ("on" or "off")
  #[arg(short, long)]
  pub get: bool,
}
