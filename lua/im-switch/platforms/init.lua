local os_utils = require("im-switch.utils.os")

local M = {}

---Get the platform module for the current OS.
---@return table?, string?
function M.get_platform()
  local os_type, err = os_utils.get_os_type()
  if err then
    return nil, err
  end

  if os_type == "windows" or os_type == "wsl" then
    return require("im-switch.platforms.windows")
  elseif os_type == "macos" then
    return require("im-switch.platforms.macos")
  elseif os_type == "linux" then
    return require("im-switch.platforms.linux")
  end

  return nil, "Unsupported OS: " .. tostring(os_type)
end

return M
