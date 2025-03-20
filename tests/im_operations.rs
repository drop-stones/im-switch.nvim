#[cfg(target_os = "windows")]
mod windows;
#[cfg(target_os = "windows")]
use windows::run;

#[cfg(target_os = "macos")]
mod macos;
#[cfg(target_os = "macos")]
use macos::run;

use libtest_mimic::Arguments;

fn main() -> std::process::ExitCode {
  let mut args: Arguments = Arguments::from_args();
  args.test_threads = Some(1); // --test-threads=1

  run(args)
}
