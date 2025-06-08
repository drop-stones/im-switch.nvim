use im_switch::macos::input_method::*;
use im_switch::util::warning_collector::WarningCollector;
use std::error::Error;

/// Tests that getting the current input method returns an available input method.
///
/// # Errors
/// Returns an error if the current input method is not available.
pub fn test_get_input_method() -> Result<(), Box<dyn Error>> {
  let current_input_method = get_input_method()?;
  if !is_input_method_available(&current_input_method)? {
    return Err(Box::from(format!(
      "get_input_method() returns unavailable input method: {}",
      current_input_method
    )));
  }
  Ok(())
}

/// Tests setting all available input methods and restoring the original input method.
///
/// # Arguments
/// * `warnings` - A warning collector for recording any failures.
///
/// # Errors
/// Returns an error if setting or restoring the input method fails.
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
  set_input_method(&original_input_method)?;

  Ok(())
}
