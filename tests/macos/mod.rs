mod tests;

use crate::common::warning_collector::WarningCollector;
use libtest_mimic::{Argumetns, Failed, Trial};
use tests::*;

pub fn run(args: Arguments) -> std::process::ExitCode {
  let warnings: std::sync::Arc<WarningCollector> = WarningCollector::new();

  let tests: Vec<Trial> = get_tests(&warnings);

  libtest_mimic::run(&args, tests).exit_code()
}

fn get_tests(warnings: &std::sync::Arc<WarningCollector>) -> Vec<Trial> {
  vec![
    Trial::test("test_get_input_method", || {
      test_get_input_method().map_err(|e| Failed::from(e.to_string()))
    }),
    Trial::test("test_set_input_method", {
      let warnings = warnings.clone();
      move || test_set_input_method(&warnings).map_err(|e| Failed::from(e.to_string()))
    }),
  ]
}
