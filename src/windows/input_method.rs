use crate::windows::error::WindowsError;
use windows::Win32::{
  Foundation::*,
  UI::{Input::Ime::*, WindowsAndMessaging::*},
};

const IMC_GETOPENSTATUS: WPARAM = WPARAM(5);
const IMC_SETOPENSTATUS: WPARAM = WPARAM(6);

/// Safely get the foreground window handle.
fn safe_get_foreground_window() -> HWND {
  unsafe { GetForegroundWindow() }
}

/// Safely get the default IME window for a given HWND.
fn safe_imm_get_default_ime_wnd(hwnd: HWND) -> HWND {
  unsafe { ImmGetDefaultIMEWnd(hwnd) }
}

/// Safely send a message to a window.
fn safe_send_message(hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM) -> LRESULT {
  unsafe { SendMessageA(hwnd, msg, wparam, lparam) }
}

/// Retrieves the IME window handle for the current foreground window.
///
/// # Errors
/// Returns `WindowsError::GetForegroundWindowFailed` or `WindowsError::ImmGetDefaultIMEWndFailed` if the handles are invalid.
fn get_im_window() -> Result<HWND, WindowsError> {
  let hwnd: HWND = safe_get_foreground_window();
  if hwnd.is_invalid() {
    return Err(WindowsError::GetForegroundWindowFailed);
  }
  let ime: HWND = safe_imm_get_default_ime_wnd(hwnd);
  if ime.is_invalid() {
    return Err(WindowsError::ImmGetDefaultIMEWndFailed);
  }
  Ok(ime)
}

/// Sets the IME open status (on/off).
///
/// # Arguments
/// * `status` - The desired IME status as a LPARAM.
///
/// # Errors
/// Returns errors from `get_im_window`.
fn set_im_state(status: LPARAM) -> Result<(), WindowsError> {
  let ime = get_im_window()?;
  safe_send_message(ime, WM_IME_CONTROL, IMC_SETOPENSTATUS, status);
  Ok(())
}

/// Gets the current IME open status as a string ("on" or "off").
///
/// # Errors
/// Returns errors from `get_im_window`.
pub fn get_im_state() -> Result<&'static str, WindowsError> {
  let ime = get_im_window()?;
  let status = safe_send_message(ime, WM_IME_CONTROL, IMC_GETOPENSTATUS, LPARAM(0));

  Ok(match status {
    windows::Win32::Foundation::LRESULT(0) => "off",
    _ => "on",
  })
}

/// Enables the input method (IME).
///
/// # Errors
/// Returns errors from `set_im_state`.
pub fn enable_im() -> Result<(), WindowsError> {
  set_im_state(LPARAM(1))
}

/// Disables the input method (IME).
///
/// # Errors
/// Returns errors from `set_im_state`.
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
