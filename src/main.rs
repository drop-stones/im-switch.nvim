use std::env;

#[cfg(target_os = "windows")]
mod windows;
#[cfg(target_os = "windows")]
use windows::ime;

#[cfg(target_os = "macos")]
mod macos;
#[cfg(target_os = "macos")]
use macos::ime;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() >= 2 {
        unsafe { ime::set_input_method(&args[1]) }
    } else {
        unsafe { println!("{}", ime::get_input_method()) }
    }
}
