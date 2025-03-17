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

unsafe fn set_ime(status: LPARAM) {
  let ime = get_ime();
  SendMessageA(ime, WM_IME_CONTROL, IMC_SETOPENSTATUS, status);
}

pub unsafe fn get_input_method() -> &'static str {
  let ime = get_ime();
  match SendMessageA(ime, WM_IME_CONTROL, IMC_GETOPENSTATUS, LPARAM(0)) {
    LRESULT { 0: 0 } => "off",
    _ => "on",
  }
}

pub unsafe fn activate_im() {
  set_ime(LPARAM(1));
}

pub unsafe fn inactivate_im() {
  set_ime(LPARAM(0));
}

#[cfg(test)]
mod tests {
  use super::*;
  use serial_test::serial;

  #[test]
  #[serial]
  fn test_activate_im() {
    unsafe { activate_im() };
    let current_im = unsafe { get_input_method() };
    assert_eq!(current_im, "on");

    // restore default im
    unsafe { inactivate_im() };
  }

  #[test]
  #[serial]
  fn test_inactivate_im() {
    unsafe { inactivate_im() };
    let current_im = unsafe { get_input_method() };
    assert_eq!(current_im, "off");
  }
}
