use crate::macos::MacOsError;
use objc2::rc::Retained;
use objc2_app_kit::{NSTextInputContext, NSTextInputSourceIdentifier};
use objc2_foundation::{MainThreadMarker, NSString};
use std::{ffi::CStr, ops::Deref, str};

/// Converts an Objective-C NSString to a Rust String safely.
/// Returns a MacOsError if UTF-8 conversion fails.
fn nsstring_to_string(nsstr: &NSString) -> Result<String, MacOsError> {
  let cstr = unsafe { CStr::from_ptr(nsstr.UTF8String()) };
  cstr
    .to_str()
    .map(|s| s.to_owned())
    .map_err(|e| MacOsError::Utf8Error(e.to_string()))
}

/// Safely retrieves the keyboard input sources from an NSTextInputContext.
/// Returns None if unavailable.
fn get_keyboard_input_sources(ctx: &NSTextInputContext) -> Option<Vec<Retained<NSString>>> {
  unsafe { ctx.keyboardInputSources() }.map(|v| v.to_vec())
}

/// Creates and returns the current input context on the main thread.
///
/// # Errors
/// Returns `MacOsError::MainThreadRequired` if not on the main thread.
fn create_input_context() -> Result<Retained<NSTextInputContext>, MacOsError> {
  let main_thread_marker: MainThreadMarker =
    MainThreadMarker::new().ok_or(MacOsError::MainThreadRequired)?;
  let current_input_context: Retained<NSTextInputContext> =
    unsafe { NSTextInputContext::new(main_thread_marker) };
  Ok(current_input_context)
}

/// Returns a list of available input methods as Strings.
///
/// # Errors
/// Returns `MacOsError` if the input context or input sources cannot be retrieved or converted.
pub fn get_available_input_methods() -> Result<Vec<String>, MacOsError> {
  let input_context: Retained<NSTextInputContext> = create_input_context()?;
  let input_sources_ns: Vec<Retained<NSString>> = get_keyboard_input_sources(&input_context)
    .ok_or_else(|| {
      MacOsError::InputSourceUnavailable("Failed to get keyboard input sources".to_string())
    })?;

  // Convert the input sources to a vector of String
  let input_sources: Vec<String> = input_sources_ns
    .into_iter()
    .map(|s| nsstring_to_string(&s))
    .collect::<Result<Vec<String>, MacOsError>>()?;

  Ok(input_sources)
}

/// Checks if a specific input method is available.
///
/// # Arguments
/// * `input_method` - The input method identifier to check.
///
/// # Errors
/// Returns `MacOsError` if the available input methods cannot be retrieved.
pub fn is_input_method_available(input_method: &str) -> Result<bool, MacOsError> {
  let available_input_methods = get_available_input_methods()?;
  Ok(available_input_methods.iter().any(|s| s == input_method))
}

/// Retrieves the currently selected input method as a String.
///
/// # Errors
/// Returns `MacOsError` if the input method cannot be retrieved or converted.
pub fn get_input_method() -> Result<String, MacOsError> {
  let input_context: Retained<NSTextInputContext> = create_input_context()?;
  let input_method_retained = input_context
    .selectedKeyboardInputSource()
    .ok_or_else(|| MacOsError::InputSourceUnavailable("Failed to get input method".to_string()))?;

  let input_method_ns: &NSString = input_method_retained.deref();

  let input_method_str: String = nsstring_to_string(input_method_ns)?;

  Ok(input_method_str)
}

/// Sets the input method for a specific input method identifier.
///
/// # Arguments
/// * `input_method` - The input method identifier to set.
///
/// # Errors
/// Returns `MacOsError` if the input method is not available or cannot be set.
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

#[cfg(test)]
mod tests {
  use super::*;
  use objc2_foundation::NSString;

  /// Tests that nsstring_to_string correctly converts a valid NSString.
  #[test]
  fn test_nsstring_to_string_valid() -> Result<(), MacOsError> {
    let nsstr = NSString::from_str("hello");
    let result = nsstring_to_string(&nsstr)?;
    assert_eq!(result, "hello");
    Ok(())
  }
}
