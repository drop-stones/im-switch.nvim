use crate::macos::WarningCollector;
use im_switch::macos::input_method::*;
use std::error::Error;

pub fn test_get_input_method() -> Result<(), Box<dyn Error>> {
  let current_input_method = get_input_method()?;
  if !is_input_method_available(current_input_method)? {
    return Err(Box::from(format!(
      "get_input_method() returns unavailable input method: {}",
      current_input_method
    )));
  }
  Ok(())
}

pub fn test_set_input_method(warnings: &WarningCollector) -> Result<(), Box<dyn Error>> {
  let original_input_method = get_input_method()?;

  // Set all available input methods
  let available_input_methods = get_available_input_methods()?;
  available_input_methods
    .iter()
    .try_for_each(|input_method| -> Result<(), Box<dyn Error>> {
      set_input_method(input_method)?;
      if get_input_method()? != *input_method {
        warnings.add_warning(format!("Failed to change input method: {}", input_method))?;
      }
      Ok(())
    })?;

  // Restore the original input method
  set_input_method(original_input_method)?;

  Ok(())
}
