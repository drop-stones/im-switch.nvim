use clap::Parser;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
#[group(multiple = false)]
pub struct Args {
    /// Set input method
    #[arg(short, long)]
    pub set: Option<String>,

    /// Get current input method
    #[arg(short, long)]
    pub get: bool,
}
