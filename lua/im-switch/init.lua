local im = require("im-switch.im")
local utils = require("im-switch.utils")

local M = {}

local default_opts = {
  set_default_im_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
  set_previous_im_events = { "InsertEnter" },
  save_im_events = { "InsertLeavePre" },
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
    ((os == "wsl" or os == "windows") and (opts.windows == nil))
    or ((os == "mac") and (opts.mac == nil))
    or ((os == "linux") and (opts.linux == nil))
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
