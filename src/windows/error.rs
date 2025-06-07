use std::fmt;

#[derive(Debug)]
pub enum WindowsError {
  GetForegroundWindowFailed,
  ImmGetDefaultIMEWndFailed,
}

impl std::error::Error for WindowsError {}

impl fmt::Display for WindowsError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      WindowsError::GetForegroundWindowFailed => write!(f, "GetForegroundWindow failed"),
      WindowsError::ImmGetDefaultIMEWndFailed => write!(f, "ImmGetDefaultIMEWnd failed"),
    }
  }
}
