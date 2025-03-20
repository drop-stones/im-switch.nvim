use im_switch::windows::im::*;
use std::error::Error;

pub fn test_activate_im() -> Result<(), Box<dyn Error>> {
  activate_im()?;
  let current_im = get_input_method()?;
  if current_im != "on" {
    return Err(format!("Expected 'on', but got '{}'", current_im).into());
  }
  Ok(())
}

pub fn test_inactivate_im() -> Result<(), Box<dyn Error>> {
  inactivate_im()?;
  let current_im = get_input_method()?;
  if current_im != "off" {
    return Err(format!("Expected 'off', but got '{}'", current_im).into());
  }
  Ok(())
}
