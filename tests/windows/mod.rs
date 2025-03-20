mod tests;

use libtest_mimic::{Arguments, Failed, Trial};
use tests::*;

pub fn run(args: Arguments) -> std::process::ExitCode {
  let tests: Vec<Trial> = get_tests();

  libtest_mimic::run(&args, tests).exit_code()
}

fn get_tests() -> Vec<Trial> {
  vec![
    Trial::test("test_enable_im", || {
      test_enable_im().map_err(|e| Failed::from(e.to_string()))
    }),
    Trial::test("test_disable_im", || {
      test_disable_im().map_err(|e| Failed::from(e.to_string()))
    }),
  ]
}
