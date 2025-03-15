local im = require("im-switch.im")
local utils = require("im-switch.utils")

---@class WindowsSettings
---@field enabled boolean

---@class MacSettings
---@field enabled boolean
---@field default_im? string

---@class LinuxSettings
---@field enabled boolean
---@field default_im? string
---@field obtain_im_command? string|string[]
---@field set_im_command? string|string[]

---@class PluginOptions
---@field set_default_im_events string[]
---@field save_im_events string[]
---@field set_previous_im_events string[]
---@field windows? WindowsSettings
---@field mac? MacSettings
---@field linux? LinuxSettings

--==============================================================
-- Local Functions
--==============================================================

--- Default plugin options
---@type PluginOptions
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

--- Initialize plugin options
---@param opts PluginOptions
---@return PluginOptions
local function initialize_opts(opts)
  -- Extend the opts with default_opts, overwriting nil values in opts with default_opts
  opts = vim.tbl_extend("force", default_opts, opts)
  return opts
end

--- Return true if the plugin is enabled for the current OS, false for otherwise
---@param opts PluginOptions
---@return boolean
local function is_enabled(opts)
  local os = utils.detect_os()

  if os == "wsl" or os == "windows" then
    return opts.windows.enabled
  elseif os == "mac" then
    return opts.mac.enabled
  elseif os == "linux" then
    return opts.linux.enabled
  else
    error("Unsupported OS")
  end
end

--==============================================================
-- Public Functions
--==============================================================

local M = {}

---@param opts PluginOptions User options
function M.setup(opts)
  -- Initialize options
  M.opts = initialize_opts(opts)

  -- If the plugin is not enabled for the current OS, exit early
  if not is_enabled(M.opts) then
    return
  end

  -- Create an autocommand group to manage the events
  local group_id = vim.api.nvim_create_augroup("im-switch", { clear = true })

  -- Set up autocommand to disable IM when events in `set_default_im_events` are triggered
  if #M.opts.set_default_im_events > 0 then
    vim.api.nvim_create_autocmd(M.opts.set_default_im_events, {
      callback = function()
        im.ime_off(M.opts)
      end,
      group = group_id,
    })
  end

  -- Set up autocommand to restore previous IM when events in `set_previous_im_events` are triggered
  if #M.opts.set_previous_im_events > 0 then
    vim.api.nvim_create_autocmd(M.opts.set_previous_im_events, {
      callback = function()
        im.restore_previous_im(M.opts)
      end,
      group = group_id,
    })
  end

  -- Set up autocommand to save the current IM when events in `save_im_events` are triggered
  if #M.opts.save_im_events > 0 then
    vim.api.nvim_create_autocmd(M.opts.save_im_events, {
      callback = function()
        im.save_im(M.opts)
      end,
      group = group_id,
    })
  end
end

return M
