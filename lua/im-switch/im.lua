local utils = require("im-switch.utils")

local M = {}

local function get_current_im(opts)
  local current_im = ""
  local os = utils.get_os()
  if (os == "wsl") or (os == "windows") then
    current_im = vim.fn.system({ utils.get_executable_path(), "--get" })
  elseif os == "mac" then
    current_im = vim.fn.system({ utils.get_executable_path(), "--get" })
  elseif os == "linux" then
    current_im = vim.fn.system(opts.linux.obtain_im_command)
  end
  return current_im:gsub("%s+", "") -- trim all spaces
end

function M.save_im(opts)
  local current_im = get_current_im(opts)
  vim.api.nvim_buf_set_var(0, "saved_im", current_im)
end

function M.ime_off(opts)
  local os = utils.get_os()
  if (os == "wsl") or (os == "windows") then
    vim.fn.system({ utils.get_executable_path(), "--inactivate" })
  elseif os == "mac" then
    vim.fn.system({ utils.get_executable_path(), "--set", opts.mac.default_im })
  elseif os == "linux" then
    vim.fn.system(opts.linux.set_im_command .. " " .. opts.linux.default_im)
  end
end

function M.restore_previous_im(opts)
  if vim.b["saved_im"] == nil then
    M.save_im(opts)
    return
  end

  local previous_im = vim.api.nvim_buf_get_var(0, "saved_im")

  local os = utils.get_os()
  if (os == "wsl") or (os == "windows") then
    if previous_im == "on" then
      vim.fn.system({ utils.get_executable_path(), "--activate" })
    elseif previous_im == "off" then
      vim.fn.system({ utils.get_executable_path(), "--inactivate" })
    end
  elseif os == "mac" then
    vim.fn.system({ utils.get_executable_path(), "--set", previous_im })
  elseif os == "linux" then
    vim.fn.system(opts.linux.set_im_command .. " " .. previous_im)
  end
end

return M
