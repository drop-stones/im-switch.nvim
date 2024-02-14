use windows::Win32::{
    Foundation::*,
    UI::{Input::Ime::*, WindowsAndMessaging::*},
};

const IMC_GETOPENSTATUS: WPARAM = WPARAM(5);
const IMC_SETOPENSTATUS: WPARAM = WPARAM(6);

unsafe fn get_ime() -> HWND {
    let hwnd: HWND = GetForegroundWindow();
    assert_ne!(hwnd, HWND(0), "Error: GetForegroundWindow failed");
    let ime: HWND = ImmGetDefaultIMEWnd(hwnd);
    assert_ne!(ime, HWND(0), "Error: ImmGetDefaultIMEWnd failed");
    ime
}

pub unsafe fn get_input_method() -> &'static str {
    let ime = get_ime();
    match SendMessageA(ime, WM_IME_CONTROL, IMC_GETOPENSTATUS, LPARAM(0)) {
        LRESULT { 0: 0 } => "off",
        _ => "on",
    }
}

pub unsafe fn set_input_method(locale: &str) {
    let stat: LPARAM = match locale {
        "on" => LPARAM(1),
        "off" => LPARAM(0),
        _ => panic!("Error: Invalid argument"),
    };
    let ime = get_ime();
    SendMessageA(ime, WM_IME_CONTROL, IMC_SETOPENSTATUS, stat);
}
