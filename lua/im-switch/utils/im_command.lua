local os_utils = require("im-switch.utils.os")
local path = require("im-switch.utils.path")

local M = {}

---Generate the command to get/set input method based on OS and options
---@param action "get"|"set"
---@param opts PluginOptions
---@param im_value? string
---@return string[]?
function M.get_im_command(action, opts, im_value)
  local os = os_utils.get_os_type()
  if os == "wsl" or os == "windows" then
    if action == "get" then
      return { path.get_executable_path(), "--get" }
    elseif action == "set" then
      if im_value and im_value == "on" then
        return { path.get_executable_path(), "--enable" }
      else
        return { path.get_executable_path(), "--disable" }
      end
    end
  elseif os == "macos" then
    if action == "get" then
      return { path.get_executable_path(), "--get" }
    elseif action == "set" then
      return { path.get_executable_path(), "--set", im_value or opts.macos.default_im }
    end
  elseif os == "linux" then
    if action == "get" then
      return opts.linux.get_im_command
    elseif action == "set" then
      local command = vim.deepcopy(opts.linux.set_im_command)
      table.insert(command, im_value or opts.linux.default_im)
      return command
    end
  end
  vim.notify("Unsupported OS or action: " .. os .. "/" .. tostring(action), vim.log.levels.ERROR)
  return nil
end

return M
