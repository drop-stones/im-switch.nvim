use crate::macos::MacOsError;
use libc::c_char;
use objc2::rc::Retained;
use objc2_app_kit::{NSTextInputContext, NSTextInputSourceIdentifier};
use objc2_foundation::{MainThreadMarker, NSString};
use std::{ffi::CStr, ops::Deref, str};

// Creates and returns the current input context on the main thread.
fn create_input_context() -> Result<Retained<NSTextInputContext>, MacOsError> {
  let main_thread_marker: MainThreadMarker =
    MainThreadMarker::new().ok_or_else(|| MacOsError::MainThreadRequired)?;
  let current_input_context: Retained<NSTextInputContext> =
    unsafe { NSTextInputContext::new(main_thread_marker) };
  Ok(current_input_context)
}

// Returns a list of available input methods
pub fn get_available_input_methods() -> Result<Vec<String>, MacOsError> {
  let input_context: Retained<NSTextInputContext> = create_input_context()?;
  let input_sources_ns: Vec<Retained<NSString>> = unsafe { input_context.keyboardInputSources() }
    .ok_or_else(|| {
      MacOsError::InputSourceUnavailable("Failed to get keyboard input sources".to_string())
    })?
    .to_vec();

  // Convert the input sources to a vector of String
  let input_sources: Vec<String> = input_sources_ns
    .into_iter()
    .map(|s| {
      unsafe { CStr::from_ptr(s.UTF8String()) }
        .to_str()
        .map(|s| s.to_owned())
        .map_err(|e| MacOsError::Utf8Error(e.to_string()))
    })
    .collect::<Result<Vec<String>, MacOsError>>()?;

  Ok(input_sources)
}

// Checks if a specific input method is available
pub fn is_input_method_available(input_method: &str) -> Result<bool, MacOsError> {
  let available_input_methods = get_available_input_methods()?;
  Ok(available_input_methods.iter().any(|s| s == input_method))
}

// Retrieves the currently selected input method
pub fn get_input_method() -> Result<String, MacOsError> {
  let input_context: Retained<NSTextInputContext> = create_input_context()?;
  let input_method_ptr: *const c_char = input_context
    .selectedKeyboardInputSource()
    .ok_or_else(|| MacOsError::InputSourceUnavailable("Failed to get input method".to_string()))?
    .deref()
    .UTF8String();

  let input_method_str: String = unsafe { CStr::from_ptr(input_method_ptr) }
    .to_str()
    .map(|s| s.to_owned())
    .map_err(|e| MacOsError::Utf8Error(e.to_string()))?;

  Ok(input_method_str)
}

// Sets the input method for a specific input method
pub fn set_input_method(input_method: &str) -> Result<(), MacOsError> {
  // Check if the specified input method is available
  if !is_input_method_available(input_method)? {
    return Err(MacOsError::InputSourceNotFound(input_method.to_string()));
  }

  // If the current input method is already the desired one, do nothing and return success.
  if get_input_method()? == input_method {
    return Ok(());
  }

  let input_context: Retained<NSTextInputContext> = create_input_context()?;
  let input_method_identifier: Retained<NSTextInputSourceIdentifier> =
    NSString::from_str(input_method);
  let input_method_ref: Option<&NSTextInputSourceIdentifier> =
    Some(input_method_identifier.deref());

  // Set the selected keyboard input source to the input method
  unsafe { input_context.setSelectedKeyboardInputSource(input_method_ref) };

  Ok(())
}
