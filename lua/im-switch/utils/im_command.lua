local os_utils = require("im-switch.utils.os")
local path = require("im-switch.utils.path")

local M = {}

---Generate the command to get/set input method based on OS and options.
---If action is "set" and im_value is nil, use the default input method for the OS.
---@param action "get"|"set"
---@param opts PluginOptions
---@param im_value? string
---@return string[]|nil, string?
function M.get_im_command(action, opts, im_value)
  -- Validate arguments
  if not action or not opts then
    return nil, "Invalid arguments: action and opts are required"
  end

  -- Detect OS type
  local os_type, err = os_utils.get_os_type()
  if err then
    return nil, err
  end

  -- If action is "set" and im_value is not provided, use the OS-specific default input method.
  if action == "set" and not im_value then
    if os_type == "macos" then
      im_value = opts.macos.default_im
    elseif os_type == "linux" then
      im_value = opts.linux.default_im
    elseif os_type == "windows" then
      im_value = "off"
    end
  end

  -- Windows/WSL: use the executable with --get/--enable/--disable
  if os_type == "wsl" or os_type == "windows" then
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
    -- Unsupported action for Windows/WSL
    return nil, "Unsupported action for Windows/WSL: " .. tostring(action)
  end

  -- macOS: use the executable with --get/--set
  if os_type == "macos" then
    local exe_path = path.get_executable_path()
    if action == "get" then
      return { exe_path, "--get" }
    elseif action == "set" then
      return { exe_path, "--set", im_value }
    end
    -- Unsupported action for macOS
    return nil, "Unsupported action for macOS: " .. tostring(action)
  end

  -- Linux: use commands from options
  if os_type == "linux" then
    if action == "get" then
      return opts.linux.get_im_command
    elseif action == "set" then
      local command = vim.deepcopy(opts.linux.set_im_command)
      table.insert(command, im_value)
      return command
    end
    -- Unsupported action for Linux
    return nil, "Unsupported action for Linux: " .. tostring(action)
  end

  -- Unsupported OS
  return nil, "Unsupported OS: " .. tostring(os_type)
end

return M
