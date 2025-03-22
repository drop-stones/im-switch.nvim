local im = require("im-switch.im")
local options = require("im-switch.options")

local M = {}

---@param opts PluginOptions User options
function M.setup(opts)
  -- Initialize options
  M.opts = options.initialize_opts(opts)

  -- If the plugin is not enabled for the current OS, exit early
  if not options.is_plugin_configured(M.opts) then
    return
  end

  -- Create an autocommand group to manage the events
  local group_id = vim.api.nvim_create_augroup("im-switch", { clear = true })

  -- Set up autocommand to set the default input method when `default_im_events` is triggered
  if #M.opts.default_im_events > 0 then
    vim.api.nvim_create_autocmd(M.opts.default_im_events, {
      callback = function()
        im.set_default_im(M.opts)
      end,
      group = group_id,
    })
  end

  -- Set up autocommand to restore the previous input method when `restore_im_events` is triggered
  if #M.opts.restore_im_events > 0 then
    vim.api.nvim_create_autocmd(M.opts.restore_im_events, {
      callback = function()
        im.restore_im(M.opts)
      end,
      group = group_id,
    })
  end

  -- Set up autocommand to save the current input method when `save_im_state_events` is triggered
  if #M.opts.save_im_state_events > 0 then
    vim.api.nvim_create_autocmd(M.opts.save_im_state_events, {
      callback = function()
        im.save_im_state(M.opts)
      end,
      group = group_id,
    })
  end
end

return M
