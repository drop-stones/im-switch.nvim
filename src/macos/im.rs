use icrate::{
    AppKit::{NSTextInputClient, NSTextInputContext, NSTextInputSourceIdentifier, NSTextView},
    Foundation::{MainThreadMarker, NSString},
};
use libc::c_char;
use objc2::{
    rc::{Allocated, Id},
    runtime::ProtocolObject,
};
use std::{ffi::CStr, ops::Deref, str};

pub unsafe fn create_input_context() -> Id<NSTextInputContext> {
    let mtm: MainThreadMarker = MainThreadMarker::new().expect("must be on the main thread");
    let text_view: Id<NSTextView> = NSTextView::new(mtm);
    let input_protocol: &ProtocolObject<dyn NSTextInputClient> =
        ProtocolObject::from_ref(&*text_view);
    let input_context: Allocated<NSTextInputContext> = mtm.alloc::<NSTextInputContext>();
    let input_context: Id<NSTextInputContext> =
        NSTextInputContext::initWithClient(input_context, input_protocol);
    input_context
}

pub unsafe fn get_input_method() -> &'static str {
    let input_context = create_input_context();
    let input_method: *mut c_char = input_context
        .selectedKeyboardInputSource()
        .unwrap()
        .deref()
        .UTF8String();
    let input_method: &CStr = CStr::from_ptr(input_method);
    input_method.to_str().unwrap()
}

pub unsafe fn set_input_method(locale: &str) {
    let input_context = create_input_context();
    let locale: Id<NSTextInputSourceIdentifier> = NSString::from_str(locale);
    let locale: Option<&NSTextInputSourceIdentifier> = Some(locale.deref());
    input_context.setSelectedKeyboardInputSource(locale)
}
