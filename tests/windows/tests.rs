//! Tests for Windows input method operations.
//!
//! Includes tests for enabling, disabling, and getting the IME state.

use im_switch::windows::input_method::*;

/// Tests that enabling the input method sets the IME state to "on".
///
/// # Errors
/// Returns an error if enabling the IME or checking its state fails.
pub fn test_enable_im() -> Result<(), Box<dyn std::error::Error>> {
  enable_im()?;
  let state = get_im_state()?;
  if state != "on" {
    return Err("IME state is not 'on' after enabling".into());
  }
  Ok(())
}

/// Tests that disabling the input method sets the IME state to "off".
///
/// # Errors
/// Returns an error if disabling the IME or checking its state fails.
pub fn test_disable_im() -> Result<(), Box<dyn std::error::Error>> {
  disable_im()?;
  let state = get_im_state()?;
  if state != "off" {
    return Err("IME state is not 'off' after disabling".into());
  }
  Ok(())
}
