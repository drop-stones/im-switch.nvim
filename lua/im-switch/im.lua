local im_command = require("im-switch.utils.im_command")

--==============================================================
-- Local Functions
--==============================================================

--- Get the current input method
---@param opts PluginOptions options
---@return string? the current input method
local function get_current_im(opts)
  local command, err = im_command.get_im_command("get", opts)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return nil
  end

  local result = vim.system(command --[[ @as string[] ]], { text = true }):wait()

  -- Handle errors from the executable
  if result.code ~= 0 then
    vim.notify("Failed to get current input method: " .. result.stderr, vim.log.levels.ERROR)
    return nil
  end

  -- Trim all spaces and return the input method
  return vim.trim(result.stdout)
end

--==============================================================
-- Public Functions
--==============================================================

local M = {}

--- Save the current input method to the buffer variable
---@param opts PluginOptions options
function M.save_im_state(opts)
  local current_im = get_current_im(opts)
  vim.api.nvim_buf_set_var(0, "saved_im_state", current_im)
end

--- Disable or set the default input method based on the operating system
---@param opts PluginOptions options
function M.set_default_im(opts)
  local command, err = im_command.get_im_command("set", opts)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return nil
  end

  local result = vim.system(command --[[ @as string[] ]], { text = true }):wait()

  -- Handle errors from the executable
  if result.code ~= 0 then
    vim.notify("Failed to set the default input method: " .. result.stderr, vim.log.levels.ERROR)
  end
end

--- Restore the previously saved input method
---@param opts PluginOptions options
function M.restore_im(opts)
  -- If no input method saved, store the current one and return
  if vim.b["saved_im_state"] == nil then
    M.save_im_state(opts)
    return
  end

  local previous_im_state = vim.api.nvim_buf_get_var(0, "saved_im_state")
  local command, err = im_command.get_im_command("set", opts, previous_im_state)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return nil
  end

  local result = vim.system(command --[[ @as string[] ]], { text = true }):wait()

  -- Check for errors in the system command
  if result.code ~= 0 then
    vim.notify("Failed to restore the previous input method: " .. result.stderr, vim.log.levels.ERROR)
  end
end

return M
