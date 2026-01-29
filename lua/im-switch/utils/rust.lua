local path = require("im-switch.utils.path")
local system = require("im-switch.utils.system")

local M = {}

---Extract required rust-version from Cargo.toml.
---@return string? version, string? err
function M.extract_rust_version()
  local filepath = path.get_plugin_path("Cargo.toml")
  local file = io.open(filepath, "r")
  if not file then
    return nil, "failed to open Cargo.toml"
  end

  for line in file:lines() do
    local rust_version = line:match('^%s*rust%-version%s*=%s*"([%d%.]+)"')
    if rust_version then
      file:close()
      return rust_version, nil
    end
  end

  file:close()
  return nil, "rust-version not found in Cargo.toml"
end

---Check if cargo is available and satisfies the required version.
---@return boolean ok, string err
function M.check_cargo_version()
  -- check if `cargo` is available
  if not system.has_command("cargo") then
    return false, "cargo not found in PATH"
  end

  -- run `cargo --version`
  local cargo_result = system.run_system({ "cargo", "--version" })
  if cargo_result.code ~= 0 or not cargo_result.stdout then
    return false, "failed to run cargo --version"
  end

  -- parse cargo version
  local cargo_ver = cargo_result.stdout:match("cargo%s+(%d+%.%d+%.%d+)")
  if not cargo_ver then
    return false, "failed to parse cargo version"
  end

  -- extract required rust version
  local required_ver, err = M.extract_rust_version()
  if not required_ver then
    return false, "failed to extract required rust version: " .. err
  end

  -- check version
  local function parse_version(ver)
    local major, minor, patch = ver:match("(%d+)%.(%d+)%.(%d+)")
    return tonumber(major), tonumber(minor), tonumber(patch)
  end

  -- parse required and current versions
  local required_major, required_minor, required_patch = parse_version(required_ver)
  local cargo_major, cargo_minor, cargo_patch = parse_version(cargo_ver)

  -- compare versions
  if
    cargo_major > required_major
    or (cargo_major == required_major and cargo_minor > required_minor)
    or (cargo_major == required_major and cargo_minor == required_minor and cargo_patch >= required_patch)
  then
    return true, "cargo version " .. cargo_ver .. " meets the requirement"
  else
    return false, "cargo version " .. cargo_ver .. " does not meet the requirement of " .. required_ver
  end
end

return M
