#[cfg(target_os = "windows")]
mod windows;
#[cfg(target_os = "windows")]
use windows::run;

#[cfg(target_os = "macos")]
mod macos;
#[cfg(target_os = "macos")]
use macos::run;

fn main() {
    run();
}
