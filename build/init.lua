-- Run cargo in installation
local utils = require("im-switch.utils")

-- Skip build if cargo is not installed
if vim.fn.executable("cargo") == 0 then
  return
end

-- Skip build if not necessary
if not utils.should_build_with_cargo() then
  return
end

-- Build the im-switch binary
-- stylua: ignore
local result = vim.system({ "cargo", "build", "--release" }, { cwd = utils.get_plugin_root_path() }):wait()

if result.code ~= 0 then
  error("Cargo build failed: " .. result.stderr)
end
