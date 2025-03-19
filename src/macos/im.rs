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
  let input_context: Retained<NSTextInputContext> = create_input_context()?;
  let locale: Retained<NSTextInputSourceIdentifier> = NSString::from_str(locale);
  let locale: Option<&NSTextInputSourceIdentifier> = Some(locale.deref());
  unsafe { input_context.setSelectedKeyboardInputSource(locale) };
  Ok(())
}
