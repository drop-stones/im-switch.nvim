local utils = require("im-switch.utils")

--- Windows settings
---@class WindowsSettings
---@field enabled boolean

--- macOS settings
---@class MacSettings
---@field enabled boolean
---@field default_im? string

--- Linux settings
---@class LinuxSettings
---@field enabled boolean
---@field default_im? string
---@field obtain_im_command? string|string[]
---@field set_im_command? string|string[]

--- Plugin options
---@class PluginOptions
---@field set_default_im_events string[]
---@field save_im_events string[]
---@field set_previous_im_events string[]
---@field windows? WindowsSettings
---@field mac? MacSettings
---@field linux? LinuxSettings

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

local M = {}

--- Initialize plugin options
---@param opts PluginOptions
---@return PluginOptions
function M.initialize_opts(opts)
  -- Extend the opts with default_opts, overwriting nil values in opts with default_opts
  return vim.tbl_extend("force", default_opts, opts)
end

--- Check if the plugin is enabled and all required settings are properly configured
---@param opts PluginOptions
---@return boolean
function M.is_plugin_configured(opts)
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

return M
