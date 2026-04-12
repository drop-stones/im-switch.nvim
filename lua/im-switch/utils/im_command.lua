local os_utils = require("im-switch.utils.os")
local path = require("im-switch.utils.path")

local ERRORS = {
  invalid_args = "Invalid arguments: action is required",
  invalid_action = "Unsupported action for %s: %s",
  invalid_os = "Unsupported OS: %s",
}

---Cached result of whether the installed im-switch CLI binary exists.
---@type boolean?
local cli_exists_cache = nil

---Check if the im-switch CLI binary exists at the install location (cached).
---@return boolean
local function is_cli_installed()
  if cli_exists_cache == nil then
    cli_exists_cache = vim.fn.executable(path.get_cli_path()) == 1
  end
  return cli_exists_cache
end

local M = {}

---Reset the CLI existence cache. Used in tests.
function M._reset_cache()
  cli_exists_cache = nil
end

---Generate the command for Windows/WSL to get/set input method.
---Uses the `ime` subcommand of the external im-switch CLI.
---@param action "get"|"set"
---@param im_value? string
---@return string[]?, string?
local function get_windows_command(action, im_value)
  local cli = path.get_cli_path()
  if action == "get" then
    return { cli, "ime", "get" }
  elseif action == "set" then
    if im_value == "enabled" then
      return { cli, "ime", "enable" }
    else
      return { cli, "ime", "disable" }
    end
  end
  return nil, string.format(ERRORS.invalid_action, "Windows/WSL", tostring(action))
end

---Generate the command for macOS to get/set input method.
---@param action "get"|"set"
---@param im_value? string
---@return string[]?, string?
local function get_macos_command(action, im_value)
  local cli = path.get_cli_path()
  if action == "get" then
    return { cli, "get" }
  elseif action == "set" then
    return { cli, "set", im_value }
  end
  return nil, string.format(ERRORS.invalid_action, "macOS", tostring(action))
end

---Check if user-configured custom commands are set for Linux.
---@param opts table
---@return boolean
local function has_custom_commands(opts)
  return opts.linux.get_im_command
    and #opts.linux.get_im_command > 0
    and opts.linux.set_im_command
    and #opts.linux.set_im_command > 0
end

---Generate the command for Linux to get/set input method.
---User-configured commands take priority over the im-switch CLI.
---@param action "get"|"set"
---@param im_value? string
---@param opts table
---@return string[]?, string?
local function get_linux_command(action, im_value, opts)
  -- User-configured commands take priority
  if has_custom_commands(opts) then
    if action == "get" then
      return opts.linux.get_im_command
    elseif action == "set" then
      local command = vim.deepcopy(opts.linux.set_im_command)
      table.insert(command, im_value)
      return command
    end
    return nil, string.format(ERRORS.invalid_action, "Linux", tostring(action))
  end

  -- Fall back to im-switch CLI
  if is_cli_installed() then
    local cli = path.get_cli_path()
    if action == "get" then
      return { cli, "get" }
    elseif action == "set" then
      return { cli, "set", im_value }
    end
    return nil, string.format(ERRORS.invalid_action, "Linux", tostring(action))
  end

  return nil, "No im-switch CLI installed and no custom commands configured for Linux"
end

---Generate the command to get/set input method based on OS and options.
---If action is "set" and im_value is nil, use the default input method for the OS.
---@param action "get"|"set"
---@param im_value? string
---@return string[]?, string?
function M.get_im_command(action, im_value)
  if not action then
    return nil, ERRORS.invalid_args
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
    elseif os_type == "windows" or os_type == "wsl" then
      im_value = "disabled"
    end
  end

  if os_type == "wsl" or os_type == "windows" then
    return get_windows_command(action, im_value)
  elseif os_type == "macos" then
    return get_macos_command(action, im_value)
  elseif os_type == "linux" then
    return get_linux_command(action, im_value, opts)
  end

  return nil, string.format(ERRORS.invalid_os, tostring(os_type))
end

return M
