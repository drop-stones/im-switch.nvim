local Path = require("plenary.path")
local notify = require("im-switch.utils.notify")
local os_utils = require("im-switch.utils.os")
local system = require("im-switch.utils.system")

---Get the root path of the plugin using git, or fallback to parent directory
---@return Path the root path
local function get_plugin_root_path()
  local path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
  local result = system.run_system({ "git", "rev-parse", "--show-toplevel" }, { cwd = path })

  if result.code ~= 0 then
    local fallback = vim.fn.fnamemodify(path, ":h:h")
    notify.error("Git command failed in directory: " .. path)
    notify.error("Error: " .. result.stderr)
    notify.warn("Falling back to: " .. fallback)
    return Path:new(fallback)
  end

  local root_path = vim.trim(result.stdout)
  return Path:new(root_path)
end

---Get the executable file extension for the current OS
---@param is_prebuilt boolean
---@return string
local function get_executable_extension(is_prebuilt)
  local os_type, err = os_utils.get_os_type()
  if err then
    notify.error(err)
    return ""
  end

  if (os_type == "wsl") or (os_type == "windows") then
    return ".exe"
  elseif os_type == "macos" then
    if is_prebuilt == true then
      return ".bin"
    end
  end
  return ""
end

local M = {}

---Get the absolute root path of the plugin
---@return string the root path
function M.get_plugin_root_path()
  return get_plugin_root_path():absolute()
end

---Get the built executable path in the release directory.
---@return Path?
function M.get_built_executable_path()
  local os_type = os_utils.get_os_type()
  if os_type == "linux" then
    notify.warn("get_built_executable_path() is not supported on Linux.")
    return nil
  end
  return get_plugin_root_path():joinpath("target/release/im-switch" .. get_executable_extension(false))
end

---Get the prebuilt executable path in the bin directory.
---@return string?
function M.get_prebuilt_executable_path()
  local os_type = os_utils.get_os_type()
  if os_type == "linux" then
    notify.warn("get_prebuilt_executable_path() is not supported on Linux.")
    return nil
  end
  return get_plugin_root_path():joinpath("bin/im-switch" .. get_executable_extension(true)):absolute()
end

---Get the appropriate executable path (built or prebuilt).
---@return string?
function M.get_executable_path()
  local os_type = os_utils.get_os_type()
  if os_type == "linux" then
    notify.warn("get_executable_path() is not supported on Linux.")
    return nil
  end
  local executable_path = M.get_built_executable_path()
  local prebuilt_executable_path = M.get_prebuilt_executable_path()
  if executable_path and executable_path:exists() then
    return executable_path:absolute()
  end
  return prebuilt_executable_path
end

return M
