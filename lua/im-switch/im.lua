local utils = require("im-switch.utils")

--==============================================================
-- Local Functions
--==============================================================

--- Get the current input method
---@param opts PluginOptions options
---@return string? the current input method
local function get_current_im(opts)
  local os = utils.detect_os()
  local command

  if os == "wsl" or os == "windows" or os == "macos" then
    command = { utils.get_executable_path(), "--get" }
  elseif os == "linux" then
    command = opts.linux.get_im_command
  else
    vim.notify("Unsupported OS: " .. os, vim.log.levels.ERROR)
    return nil
  end

  local result = vim.system(command, { text = true }):wait()

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
  local os = utils.detect_os()
  local result

  if (os == "wsl") or (os == "windows") then
    result = vim.system({ utils.get_executable_path(), "--disable" }):wait()
  elseif os == "macos" then
    result = vim.system({ utils.get_executable_path(), "--set", opts.macos.default_im }):wait()
  elseif os == "linux" then
    local command = vim.deepcopy(opts.linux.set_im_command)
    table.insert(command, opts.linux.default_im)
    result = vim.system(command):wait()
  else
    vim.notify("Unsupported OS", vim.log.levels.ERROR)
    return
  end

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
  local os = utils.detect_os()

  local result

  if (os == "wsl") or (os == "windows") then
    if previous_im_state == "on" then
      result = vim.system({ utils.get_executable_path(), "--enable" }):wait()
    elseif previous_im_state == "off" then
      result = vim.system({ utils.get_executable_path(), "--disable" }):wait()
    end
  elseif os == "macos" then
    result = vim.system({ utils.get_executable_path(), "--set", previous_im_state }):wait()
  elseif os == "linux" then
    local command = vim.deepcopy(opts.linux.set_im_command)
    table.insert(command, previous_im_state)
    result = vim.system(command):wait()
  else
    vim.notify("Unsupported OS", vim.log.levels.ERROR)
    return
  end

  -- Check for errors in the system command
  if result.code ~= 0 then
    vim.notify("Failed to restore the previous input method: " .. result.stderr, vim.log.levels.ERROR)
  end
end

return M
