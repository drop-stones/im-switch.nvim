local im_command = require("im-switch.utils.im_command")
local notify = require("im-switch.utils.notify")
local system = require("im-switch.utils.system")

local M = {}

---Set the default input method for the current OS.
---@return boolean
function M.set_default_im()
  local command, err = im_command.get_im_command("set")
  if err then
    notify.error(err)
    return false
  end

  local result = system.run_system(command --[[ @as string[] ]])
  if result.code ~= 0 then
    notify.error("Failed to set the default input method: " .. result.stderr)
    return false
  end

  return true
end

---Save the current input method state.
---@return boolean
function M.save_im_state()
  local command, err = im_command.get_im_command("get")
  if err then
    notify.error(err)
    return false
  end

  local result = system.run_system(command --[[ @as string[] ]])
  if result.code ~= 0 then
    notify.error("Failed to get current input method: " .. result.stderr)
    return false
  end

  -- Save the current IM state per buffer for later restoration
  vim.b.im_switch_last_state = vim.trim(result.stdout)
  return true
end

---Restore the previously saved input method state.
---@return boolean
function M.restore_im()
  -- If no previous state for this buffer, get current IM and save it
  if not vim.b.im_switch_last_state then
    if not M.save_im_state() then
      return false
    end
  end

  local command, err = im_command.get_im_command("set", vim.b.im_switch_last_state)
  if err then
    notify.error(err)
    return false
  end

  local result = system.run_system(command --[[ @as string[] ]])
  if result.code ~= 0 then
    notify.error("Failed to restore the previous input method: " .. result.stderr)
    return false
  end

  return true
end

return M
