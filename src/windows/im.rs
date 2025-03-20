use std::error::Error;
use windows::Win32::{
  Foundation::*,
  UI::{Input::Ime::*, WindowsAndMessaging::*},
};

const IMC_GETOPENSTATUS: WPARAM = WPARAM(5);
const IMC_SETOPENSTATUS: WPARAM = WPARAM(6);

fn get_ime() -> Result<HWND, Box<dyn Error>> {
  unsafe {
    let hwnd: HWND = GetForegroundWindow();
    if hwnd.is_invalid() {
      return Err("Error: GetForegroundWindow failed".into());
    }
    let ime: HWND = ImmGetDefaultIMEWnd(hwnd);
    if ime.is_invalid() {
      return Err("Error: ImmGetDefaultIMEWnd failed".into());
    }
    Ok(ime)
  }
}

fn set_ime(status: LPARAM) -> Result<(), Box<dyn Error>> {
  let ime = get_ime()?;
  unsafe { SendMessageA(ime, WM_IME_CONTROL, IMC_SETOPENSTATUS, status) };
  Ok(())
}

pub fn get_input_method() -> Result<&'static str, Box<dyn Error>> {
  let ime = get_ime()?;
  let status = unsafe { SendMessageA(ime, WM_IME_CONTROL, IMC_GETOPENSTATUS, LPARAM(0)) };

  Ok(match status.0 {
    0 => "off",
    _ => "on",
  })
}

pub fn activate_im() -> Result<(), Box<dyn Error>> {
  set_ime(LPARAM(1))
}

pub fn inactivate_im() -> Result<(), Box<dyn Error>> {
  set_ime(LPARAM(0))
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_get_ime() -> Result<(), Box<dyn Error>> {
    get_ime()?;
    Ok(())
  }

  #[test]
  fn test_set_ime() -> Result<(), Box<dyn Error>> {
    set_ime(LPARAM(0))?;
    Ok(())
  }
}
