use std::fmt;

#[derive(Debug)]
pub enum MacOsError {
  MainThreadRequired,
  InputSourceNotFound(String),
  InputSourceUnavailable(String),
  Utf8Error(String),
}

impl std::error::Error for MacOsError {}

impl fmt::Display for MacOsError {
  fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
    match self {
      MacOsError::MainThreadRequired => write!(f, "Operation must be run on the main thread"),
      MacOsError::InputSourceNotFound(s) => write!(f, "Input source not found: {}", s),
      MacOsError::InputSourceUnavailable(s) => write!(f, "Input source unavailable: {}", s),
      MacOsError::Utf8Error(e) => write!(f, "UTF-8 conversion error: {}", e),
    }
  }
}
