local os_utils = require("im-switch.utils.os")
local path = require("im-switch.utils.path")

local M = {}

---Generate the command for Windows/WSL to get/set input method.
---@param action "get"|"set"
---@param im_value? string
---@return string[]?, string?
local function get_windows_command(action, im_value)
  local exe_path = path.get_executable_path()
  if action == "get" then
    return { exe_path, "--get" }
  elseif action == "set" then
    if im_value == "on" then
      return { exe_path, "--enable" }
    else
      return { exe_path, "--disable" }
    end
  end
  return nil, "Unsupported action for Windows/WSL: " .. tostring(action)
end

---Generate the command for macOS to get/set input method.
---@param action "get"|"set"
---@param im_value? string
---@return string[]?, string?
local function get_macos_command(action, im_value)
  local exe_path = path.get_executable_path()
  if action == "get" then
    return { exe_path, "--get" }
  elseif action == "set" then
    return { exe_path, "--set", im_value }
  end
  return nil, "Unsupported action for macOS: " .. tostring(action)
end

---Generate the command for Linux to get/set input method.
---@param action "get"|"set"
---@param im_value? string
---@param opts table
---@return string[]?, string?
local function get_linux_command(action, im_value, opts)
  if action == "get" then
    return opts.linux.get_im_command
  elseif action == "set" then
    local command = vim.deepcopy(opts.linux.set_im_command)
    table.insert(command, im_value)
    return command
  end
  return nil, "Unsupported action for Linux: " .. tostring(action)
end

---Generate the command to get/set input method based on OS and options.
---If action is "set" and im_value is nil, use the default input method for the OS.
---@param action "get"|"set"
---@param im_value? string
---@return string[]?, string?
function M.get_im_command(action, im_value)
  if not action then
    return nil, "Invalid arguments: action is required"
  end

  local opts = require("im-switch.options").get()
  local os_type, err = os_utils.get_os_type()
  if err then
    return nil, err
  end

  if action == "set" and not im_value then
    if os_type == "macos" then
      im_value = opts.macos.default_im
    elseif os_type == "linux" then
      im_value = opts.linux.default_im
    elseif os_type == "windows" then
      im_value = "off"
    end
  end

  if os_type == "wsl" or os_type == "windows" then
    return get_windows_command(action, im_value)
  elseif os_type == "macos" then
    return get_macos_command(action, im_value)
  elseif os_type == "linux" then
    return get_linux_command(action, im_value, opts)
  end

  return nil, "Unsupported OS: " .. tostring(os_type)
end

return M
