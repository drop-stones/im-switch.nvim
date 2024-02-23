local im = require("im-switch.im")
local utils = require("im-switch.utils")

local M = {}

local default_opts = {
  set_default_im_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
  set_previous_im_events = { "InsertEnter" },
  save_im_events = { "InsertLeavePre" },

  windows = {
    enabled = false,
  },

  mac = {
    enabled = false,
  },

  linux = {
    enabled = false,
  },
}

local function initialize_opts(opts)
  if opts.set_default_im_events == nil then
    opts.set_default_im_events = default_opts.set_default_im_events
  end

  if opts.set_previous_im_events == nil then
    opts.set_previous_im_events = default_opts.set_previous_im_events
  end

  if opts.save_im_events == nil then
    opts.save_im_events = default_opts.save_im_events
  end

  if opts.windows == nil or opts.windows.enabled == nil then
    opts.windows = default_opts.windows
  end

  if opts.mac == nil or opts.mac.enabled == nil then
    opts.mac = default_opts.mac
  end

  if opts.linux == nil or opts.linux.enabled == nil then
    opts.linux = default_opts.linux
  end

  if utils.get_os() == "linux" then
    opts.linux.obtain_im_command = utils.concat(opts.linux.obtain_im_command)
    opts.linux.set_im_command = utils.concat(opts.linux.set_im_command)
  end

  return opts
end

function M.setup(opts)
  -- Initialize options
  opts = initialize_opts(opts)

  local os = utils.get_os()

  -- Check options for mac
  if
    ((os == "wsl" or os == "windows") and (opts.windows.enabled == false))
    or ((os == "mac") and opts.mac.enabled == false)
    or ((os == "linux") and opts.linux.enabled == false)
  then
    return
  end

  -- Setup autocommand functions
  local group_id = vim.api.nvim_create_augroup("im-switch", { clear = true })

  if #opts.set_default_im_events > 0 then
    vim.api.nvim_create_autocmd(opts.set_default_im_events, {
      callback = function()
        im.ime_off(opts)
      end,
      group = group_id,
    })
  end

  if #opts.set_previous_im_events > 0 then
    vim.api.nvim_create_autocmd(opts.set_previous_im_events, {
      callback = function()
        im.restore_previous_im(opts)
      end,
      group = group_id,
    })
  end

  if #opts.save_im_events > 0 then
    vim.api.nvim_create_autocmd(opts.save_im_events, {
      callback = function()
        im.save_im(opts)
      end,
      group = group_id,
    })
  end
end

return M
