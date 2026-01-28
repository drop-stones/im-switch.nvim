local system = require("im-switch.utils.system")

---Check if cargo is available and satisfies the required version.
---@param required_version string e.g. "1.93.0"
---@return boolean ok, string err
local function check_cargo_version(required_version)
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

  -- check version
  local function parse_version(ver)
    local major, minor, patch = ver:match("(%d+)%.(%d+)%.(%d+)")
    return tonumber(major), tonumber(minor), tonumber(patch)
  end

  -- parse required and current versions
  local required_major, required_minor, required_patch = parse_version(required_version)
  local cargo_major, cargo_minor, cargo_patch = parse_version(cargo_ver)

  -- compare versions
  if
    cargo_major > required_major
    or (cargo_major == required_major and cargo_minor > required_minor)
    or (cargo_major == required_major and cargo_minor == required_minor and cargo_patch >= required_patch)
  then
    return true, "cargo version " .. cargo_ver .. " meets the requirement"
  else
    return false, "cargo version " .. cargo_ver .. " does not meet the requirement of " .. required_version
  end
end

return {
  check_cargo_version = check_cargo_version,
}
