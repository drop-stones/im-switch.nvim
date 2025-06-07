local im_command = require("im-switch.utils.im_command")
local options = require("im-switch.options")

---@type string?
local last_im_state = nil

local M = {}

---Set the default input method for the current OS.
---@return boolean
function M.set_default_im()
  local command, err = im_command.get_im_command("set")
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end

  local result = vim.system(command --[[ @as string[] ]], { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("Failed to set the default input method: " .. result.stderr, vim.log.levels.ERROR)
    return false
  end

  return true
end

---Save the current input method state.
---@return boolean
function M.save_im_state()
  local command, err = im_command.get_im_command("get")
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end

  local result = vim.system(command --[[ @as string[] ]], { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("Failed to get current input method: " .. result.stderr, vim.log.levels.ERROR)
    return false
  end

  -- Save the current IM state to options for later restoration
  last_im_state = vim.trim(result.stdout)
  return true
end

---Restore the previously saved input method state.
---@return boolean
function M.restore_im()
  -- If no previous state, get current IM and save it
  if not last_im_state then
    M.save_im_state()
  end

  local command, err = im_command.get_im_command("set", last_im_state)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end

  local result = vim.system(command --[[ @as string[] ]], { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("Failed to restore the previous input method: " .. result.stderr, vim.log.levels.ERROR)
    return false
  end

  return true
end

return M
