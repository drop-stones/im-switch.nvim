local im = require("im-switch.im")
local options = require("im-switch.options")

local M = {}

---@param user_opts table? User options
function M.setup(user_opts)
  -- Setup options
  options.setup(user_opts or {})
  local opts = options.get()

  -- Validate user options (type, required fields, etc.)
  if not options.validate_options(opts) then
    return
  end

  -- Check if the plugin should be enabled for this OS and configuration
  if not options.is_plugin_enabled(opts) then
    return
  end

  -- Create an autocommand group to manage the events
  local group_id = vim.api.nvim_create_augroup("im-switch", { clear = true })

  -- Always set default IM on these events
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" }, {
    callback = function()
      im.set_default_im()
    end,
    group = group_id,
  })

  -- In restore mode, save/restore IM state around insert mode
  if opts.mode == "restore" then
    vim.api.nvim_create_autocmd("InsertLeavePre", {
      callback = function()
        im.save_im_state()
      end,
      group = group_id,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
      callback = function()
        im.restore_im()
      end,
      group = group_id,
    })
  end
end

return M
