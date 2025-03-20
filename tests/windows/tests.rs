use im_switch::windows::input_method::*;
use std::error::Error;

pub fn test_enable_im() -> Result<(), Box<dyn Error>> {
  enable_im()?;
  let current_im = get_im_state()?;
  if current_im != "on" {
    return Err(format!("Expected 'on', but got '{}'", current_im).into());
  }
  Ok(())
}

pub fn test_disable_im() -> Result<(), Box<dyn Error>> {
  disable_im()?;
  let current_im = get_im_state()?;
  if current_im != "off" {
    return Err(format!("Expected 'off', but got '{}'", current_im).into());
  }
  Ok(())
}
