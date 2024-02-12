use std::env;

#[cfg(target_os = "windows")]
mod windows;
#[cfg(target_os = "windows")]
use windows::im;

#[cfg(target_os = "macos")]
mod macos;
#[cfg(target_os = "macos")]
use macos::im;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() >= 2 {
        unsafe { im::set_input_method(&args[1]) }
    } else {
        unsafe { println!("{}", im::get_input_method()) }
    }
}
