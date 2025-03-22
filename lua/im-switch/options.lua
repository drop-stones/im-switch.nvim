local utils = require("im-switch.utils")

--- Windows settings
---@class WindowsSettings
---@field enabled boolean

--- macOS settings
---@class MacosSettings
---@field enabled boolean
---@field default_im? string

--- Linux settings
---@class LinuxSettings
---@field enabled boolean
---@field default_im? string
---@field get_im_command? string|string[]
---@field set_im_command? string|string[]

--- Plugin options
---@class PluginOptions
---@field default_im_events string[]
---@field save_im_state_events string[]
---@field restore_im_events string[]
---@field windows? WindowsSettings
---@field macos? MacosSettings
---@field linux? LinuxSettings

--- Default plugin options
---@type PluginOptions
local default_opts = {
  -- Events that set the default input method.
  default_im_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },

  -- Events that save the current input method state.
  save_im_state_events = { "InsertLeavePre" },

  -- Events that restore the previously saved input method.
  restore_im_events = { "InsertEnter" },

  -- Windows settings
  windows = {
    -- Enable or disable the plugin on Windows/WSL2.
    enabled = false,
  },

  -- macOS settings
  macos = {
    -- Enable or disable the plugin on macOS.
    enabled = false,

    -- The input method set when `default_im_events` is triggered.
    default_im = "",
  },

  -- Linux settings
  linux = {
    -- Enable or disable the plugin on Linux.
    enabled = false,

    -- The input method set when `default_im_events` is triggered.
    default_im = "",

    -- The command used to get the current input method when `save_im_state_events` is triggered.
    get_im_command = {},

    -- The command used to set the input method when `default_im_events` or `restore_im_events` is triggered.
    set_im_command = {},
  },
}

--- Migrate a deprecated option to a new option name
---@param new string
---@param old string
---@param opts PluginOptions
local function migrate_option(new, old, opts)
  if opts[old] ~= nil then
    opts[new] = opts[old]
    vim.notify(
      string.format("[im-switch.nvim] '%s' is deprecated. Use '%s' instead.", old, new),
      vim.log.levels.WARN,
      { title = "im-switch.nvim" }
    )
  end
end

local M = {}

--- Initialize plugin options
---@param opts PluginOptions
---@return PluginOptions
function M.initialize_opts(opts)
  -- NOTE: Migration from old to new options
  migrate_option("macos", "mac", opts)
  migrate_option("default_im_events", "set_default_im_events", opts)
  migrate_option("restore_im_events", "set_previous_im_events", opts)
  migrate_option("save_im_state_events", "save_im_events", opts)
  migrate_option("get_im_command", "get_im_command", opts)

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
  elseif os == "macos" then
    if opts.macos.enabled and not opts.macos.default_im then
      error("The 'macos.default_im' field must be defined when macos plugin is enabled")
      return false
    end
    return opts.macos.enabled
  elseif os == "linux" then
    if opts.linux.enabled then
      local required_fields = { "default_im", "get_im_command", "set_im_command" }
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
