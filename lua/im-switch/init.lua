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
  return vim.tbl_extend("force", default_opts, opts)
end

--- Check if the plugin is enabled and all required settings are properly configured
---@param opts PluginOptions
---@return boolean
local function is_plugin_configured(opts)
  local os = utils.detect_os()

  if os == "wsl" or os == "windows" then
    return opts.windows.enabled
  elseif os == "mac" then
    if opts.mac.enabled and not opts.mac.default_im then
      error("The 'mac.default_im' field must be defined when mac plugin is enabled")
      return false
    end
    return opts.mac.enabled
  elseif os == "linux" then
    if opts.linux.enabled then
      local required_fields = { "default_im", "obtain_im_command", "set_im_command" }
      for _, field in ipairs(required_fields) do
        if not opts.linux[field] then
          error(string.format("The 'linux.%s' field must be defined when linux plugin is enabled", field))
          return false
        end
      end
      return true
    end
    return false
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
  if not is_plugin_configured(M.opts) then
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
