use libc::c_char;
use objc2::rc::{Allocated, Retained};
use objc2::runtime::ProtocolObject;
use objc2_app_kit::{
  NSTextInputClient, NSTextInputContext, NSTextInputSourceIdentifier, NSTextView,
};
use objc2_foundation::{MainThreadMarker, NSString};
use std::error::Error;
use std::{ffi::CStr, ops::Deref, str};

pub fn create_input_context() -> Result<Retained<NSTextInputContext>, Box<dyn Error>> {
  let mtm: MainThreadMarker =
    MainThreadMarker::new().ok_or_else(|| "must be on the main thread".to_string())?;
  let text_view: Retained<NSTextView> = unsafe { NSTextView::new(mtm) };
  let input_protocol: &ProtocolObject<dyn NSTextInputClient> =
    ProtocolObject::from_ref(&*text_view);
  let input_context: Allocated<NSTextInputContext> = mtm.alloc::<NSTextInputContext>();
  let input_context: Retained<NSTextInputContext> =
    unsafe { NSTextInputContext::initWithClient(input_context, input_protocol) };
  Ok(input_context)
}

// Returns a list of available input methods
pub fn get_available_input_methods() -> Result<Vec<&'static str>, Box<dyn Error>> {
  let input_context: Retained<NSTextInputContext> = create_input_context()?;
  let input_sources_ns: Vec<Retained<NSString>> = unsafe { input_context.keyboardInputSources() }
    .ok_or_else(|| "Failed to get keyboard input sources".to_string())?
    .to_vec();

  // Convert the input sources to a vector of &str
  let input_sources: Vec<&str> = input_sources_ns
    .into_iter()
    .map(|s| {
      unsafe { CStr::from_ptr(s.UTF8String()) }
        .to_str()
        .map_err(|e| e.to_string())
    })
    .collect::<Result<Vec<&str>, String>>()?;

  Ok(input_sources)
}

// Checks if a specific input method is available
pub fn is_input_method_available(input_method: &str) -> Result<bool, Box<dyn Error>> {
  let available_input_methods = get_available_input_methods()?;
  Ok(available_input_methods.contains(&input_method))
}

pub fn get_input_method() -> Result<&'static str, Box<dyn Error>> {
  let input_context: Retained<NSTextInputContext> = create_input_context()?;
  let input_method: *const c_char = input_context
    .selectedKeyboardInputSource()
    .ok_or_else(|| "Failed to get input method".to_string())?
    .deref()
    .UTF8String();
  let input_method: &CStr = unsafe { CStr::from_ptr(input_method) };
  let input_method: &'static str = input_method.to_str().map_err(|e| e.to_string())?;
  Ok(input_method)
}

pub fn set_input_method(locale: &str) -> Result<(), Box<dyn Error>> {
  // Check if the specified input method is available
  if !is_input_method_available(input_method)? {
    return Err(Box::from(format!(
      "Input method not available for input method: {}",
      input_method
    )));
  }

  // If the current input method is already the desired one, do nothing and return success.
  if get_input_method()? == input_method {
    return Ok(());
  }

  let input_context: Retained<NSTextInputContext> = create_input_context()?;
  let locale: Retained<NSTextInputSourceIdentifier> = NSString::from_str(locale);
  let locale: Option<&NSTextInputSourceIdentifier> = Some(locale.deref());
  unsafe { input_context.setSelectedKeyboardInputSource(locale) };
  Ok(())
}
