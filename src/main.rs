use std::env;
use windows::Win32::{
    Foundation::*,
    UI::{Input::Ime::*, WindowsAndMessaging::*},
};

const IMC_GETOPENSTATUS: WPARAM = WPARAM { 0: 5 };
const IMC_SETOPENSTATUS: WPARAM = WPARAM { 0: 6 };

unsafe fn get_ime() -> HWND {
    let hwnd: HWND = GetForegroundWindow();
    assert_ne!(hwnd, HWND { 0: 0 }, "Error: GetForegroundWindow failed");
    let ime: HWND = ImmGetDefaultIMEWnd(hwnd);
    assert_ne!(ime, HWND { 0: 0 }, "Error: ImmGetDefaultIMEWnd failed");
    ime
}

unsafe fn get_ime_status() -> bool {
    let ime = get_ime();
    match SendMessageA(ime, WM_IME_CONTROL, IMC_GETOPENSTATUS, LPARAM { 0: 0 }) {
        LRESULT { 0: 0 } => false,
        _ => true,
    }
}

unsafe fn set_ime_status(stat: bool) {
    let stat: LPARAM = match stat {
        false => LPARAM { 0: 0 },
        true => LPARAM { 0: 1 },
    };
    let ime = get_ime();
    SendMessageA(ime, WM_IME_CONTROL, IMC_SETOPENSTATUS, stat);
}

fn main() {
    let args: Vec<String> = env::args().collect();

    let stat: bool;
    if args.len() >= 2 {
        stat = match &*args[1] {
            "on" | "open" | "1" => true,
            "off" | "close" | "0" => false,
            _ => panic!("Error: Invalid argument"),
        };
        unsafe {
            set_ime_status(stat);
        }
    } else {
        unsafe {
            stat = get_ime_status();
            println!("{}", stat);
        }
    }
}
