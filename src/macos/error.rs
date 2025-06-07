use thiserror::Error;

#[derive(Debug, Error)]
pub enum MacOsError {
  #[error("IO error: {0}")]
  Io(#[from] std::io::Error),
  #[error("Operation must be run on the main thread")]
  MainThreadRequired,
  #[error("Input source not found: {0}")]
  InputSourceNotFound(String),
  #[error("Input source unavailable: {0}")]
  InputSourceUnavailable(String),
  #[error("UTF-8 conversion error: {0}")]
  Utf8Error(String),
}
