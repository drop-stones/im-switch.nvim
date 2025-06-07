use crate::windows::error::WindowsError;
use windows::Win32::{
  Foundation::*,
  UI::{Input::Ime::*, WindowsAndMessaging::*},
};

const IMC_GETOPENSTATUS: WPARAM = WPARAM(5);
const IMC_SETOPENSTATUS: WPARAM = WPARAM(6);

fn get_im_window() -> Result<HWND, WindowsError> {
  unsafe {
    let hwnd: HWND = GetForegroundWindow();
    if hwnd.is_invalid() {
      return Err(WindowsError::GetForegroundWindowFailed);
    }
    let ime: HWND = ImmGetDefaultIMEWnd(hwnd);
    if ime.is_invalid() {
      return Err(WindowsError::ImmGetDefaultIMEWndFailed);
    }
    Ok(ime)
  }
}

fn set_im_state(status: LPARAM) -> Result<(), WindowsError> {
  let ime = get_im_window()?;
  unsafe { SendMessageA(ime, WM_IME_CONTROL, IMC_SETOPENSTATUS, status) };
  Ok(())
}

pub fn get_im_state() -> Result<&'static str, WindowsError> {
  let ime = get_im_window()?;
  let status = unsafe { SendMessageA(ime, WM_IME_CONTROL, IMC_GETOPENSTATUS, LPARAM(0)) };

  Ok(match status.0 {
    0 => "off",
    _ => "on",
  })
}

pub fn enable_im() -> Result<(), WindowsError> {
  set_im_state(LPARAM(1))
}

pub fn disable_im() -> Result<(), WindowsError> {
  set_im_state(LPARAM(0))
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_get_im_window() -> Result<(), WindowsError> {
    get_im_window()?;
    Ok(())
  }

  #[test]
  fn test_set_im_state() -> Result<(), WindowsError> {
    set_im_state(LPARAM(0))?;
    Ok(())
  }
}
