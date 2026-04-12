local platforms = require("im-switch.platforms")

local M = {}

---Reset the CLI existence cache (Linux). Used in tests.
function M._reset_cache()
  local ok, linux = pcall(require, "im-switch.platforms.linux")
  if ok then
    linux._reset_cache()
  end
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

  local platform, err = platforms.get_platform()
  if err then
    return nil, err
  end

  local opts = require("im-switch.options").get()

  if action == "set" and not im_value then
    im_value = platform.default_im_value(opts)
  end

  return platform.get_im_command(action, im_value, opts)
end

return M
