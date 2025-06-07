use thiserror::Error;

#[derive(Debug, Error)]
pub enum WindowsError {
  #[error("IO error: {0}")]
  Io(#[from] std::io::Error),
  #[error("GetForegroundWindow failed")]
  GetForegroundWindowFailed,
  #[error("ImmGetDefaultIMEWnd failed")]
  ImmGetDefaultIMEWndFailed,
}
