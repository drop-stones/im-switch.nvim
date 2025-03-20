use std::error::Error;
use std::sync::{Arc, Mutex};

/// A thread-safe warning collector that stores and prints warnings on drop.
#[derive(Debug)]
pub struct WarningCollector {
  warnings: Mutex<Vec<String>>, // A mutex-protected vector to store warnings safely across threads
}

impl WarningCollector {
  /// Creates a new instance of `WarningCollector` wrapped in an `Arc`.
  pub fn new() -> Arc<Self> {
    Arc::new(Self {
      warnings: Mutex::new(Vec::new()), // Initialize with an empty vector
    })
  }

  /// Adds a warning message to the collector.
  /// Returns `Err` if acquiring the mutex lock fails.
  pub fn add_warning(&self, msg: String) -> Result<(), Box<dyn Error>> {
    let mut warnings = self
      .warnings
      .lock()
      .map_err(|e| format!("Mutex lock failed: {}", e))?; // Handle mutex lock failure
    warnings.push(msg); // Store the warning message
    Ok(())
  }
}

impl Drop for WarningCollector {
  /// Prints all collected warnings when the `WarningCollector` is dropped.
  fn drop(&mut self) {
    match self.warnings.lock() {
      Ok(warnings) => {
        if !warnings.is_empty() {
          println!("\n=== Warnings Summary ===");
          for warning in warnings.iter() {
            println!("{}", warning);
          }
          println!("========================\n");
        }
      }
      Err(e) => eprintln!("Error: Failed to acquire mutex lock in Drop: {}", e),
    }
  }
}
