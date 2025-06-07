local im = require("im-switch.im")
local options = require("im-switch.options")

local M = {}

---@param user_opts table User options
function M.setup(user_opts)
  -- If the plugin is not enabled for the current OS, exit early
  if not options.is_plugin_configured(user_opts) then
    return
  end

  -- Setup options
  options.setup(user_opts)
  local opts = options.get()

  -- Create an autocommand group to manage the events
  local group_id = vim.api.nvim_create_augroup("im-switch", { clear = true })

  -- Set up autocommand to set the default input method when `default_im_events` is triggered
  if #opts.default_im_events > 0 then
    vim.api.nvim_create_autocmd(opts.default_im_events, {
      callback = function()
        im.set_default_im()
      end,
      group = group_id,
    })
  end

  -- Set up autocommand to restore the previous input method when `restore_im_events` is triggered
  if #opts.restore_im_events > 0 then
    vim.api.nvim_create_autocmd(opts.restore_im_events, {
      callback = function()
        im.restore_im()
      end,
      group = group_id,
    })
  end

  -- Set up autocommand to save the current input method when `save_im_state_events` is triggered
  if #opts.save_im_state_events > 0 then
    vim.api.nvim_create_autocmd(opts.save_im_state_events, {
      callback = function()
        im.save_im_state()
      end,
      group = group_id,
    })
  end
end

return M
