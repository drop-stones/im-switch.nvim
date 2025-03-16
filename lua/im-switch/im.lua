local utils = require("im-switch.utils")

--==============================================================
-- Local Functions
--==============================================================

--- Get the current input method
---@param opts PluginOptions options
---@return string the current input method
local function get_current_im(opts)
  local os = utils.detect_os()
  local command

  if os == "wsl" or os == "windows" or os == "mac" then
    command = { utils.get_executable_path(), "--get" }
  elseif os == "linux" then
    command = utils.split(opts.linux.obtain_im_command)
  else
    error("Unsupported OS: " .. os)
  end

  local result = vim.system(command, { text = true }):wait()

  if result.code ~= 0 then
    error("Failed to get current input method: " .. result.stderr)
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
function M.save_im(opts)
  local current_im = get_current_im(opts)
  vim.api.nvim_buf_set_var(0, "saved_im", current_im)
end

--- Deactivate or set the input method based on the operating system
---@param opts PluginOptions options
function M.ime_off(opts)
  local os = utils.detect_os()
  local result

  if (os == "wsl") or (os == "windows") then
    result = vim.system({ utils.get_executable_path(), "--inactivate" }):wait()
  elseif os == "mac" then
    result = vim.system({ utils.get_executable_path(), "--set", opts.mac.default_im }):wait()
  elseif os == "linux" then
    local command = utils.split(opts.linux.set_im_command)
    table.insert(command, opts.linux.default_im)
    result = vim.system(command):wait()
  else
    error("Unsupported OS")
  end

  if result.code ~= 0 then
    vim.api.nvim_err_writeln("Error deactivating input method: " .. result.stderr)
  end
end

--- Restore the previously saved input method
---@param opts PluginOptions options
function M.restore_previous_im(opts)
  -- If no saved IM is found, save the current one and return
  if vim.b["saved_im"] == nil then
    M.save_im(opts)
    return
  end

  local previous_im = vim.api.nvim_buf_get_var(0, "saved_im")
  local os = utils.detect_os()

  local result

  if (os == "wsl") or (os == "windows") then
    if previous_im == "on" then
      result = vim.system({ utils.get_executable_path(), "--activate" }):wait()
    elseif previous_im == "off" then
      result = vim.system({ utils.get_executable_path(), "--inactivate" }):wait()
    end
  elseif os == "mac" then
    result = vim.system({ utils.get_executable_path(), "--set", previous_im }):wait()
  elseif os == "linux" then
    local command = utils.split(opts.linux.set_im_command)
    table.insert(command, previous_im)
    result = vim.system(command):wait()
  else
    error("Unsupported OS")
  end

  -- Check for errors in the system command
  if result.code ~= 0 then
    vim.api.nvim_err_writeln("Error restoring previous input method: " .. result.stderr)
  end
end

return M
