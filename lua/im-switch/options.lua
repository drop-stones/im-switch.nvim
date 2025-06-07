local notify = require("im-switch.utils.notify")
local os_utils = require("im-switch.utils.os")

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

local M = {}

---@type PluginOptions
M.options = default_opts

---Setup plugin options
---@param opts PluginOptions
function M.setup(opts)
  -- Extend the opts with default_opts, overwriting nil values in opts with default_opts
  M.options = vim.tbl_deep_extend("force", default_opts, opts or {})
end

---Get plugin options
---@return PluginOptions
function M.get()
  return M.options
end

---Validate user options and notify errors if invalid.
---@param opts table
---@return boolean
function M.validate_options(opts)
  if type(opts) ~= "table" then
    notify.error("Options must be a table")
    return false
  end

  if opts.macos and opts.macos.enabled and not opts.macos.default_im then
    notify.error("The 'macos.default_im' field must be defined when macos plugin is enabled")
    return false
  end
  if opts.linux and opts.linux.enabled then
    local required_fields = { "default_im", "get_im_command", "set_im_command" }
    for _, field in ipairs(required_fields) do
      if not opts.linux[field] then
        notify.error(string.format("The 'linux.%s' field must be defined when linux plugin is enabled", field))
        return false
      end
    end
  end
  return true
end

---Check if the plugin should be enabled for the current OS and options.
---@param opts table
---@return boolean
function M.is_plugin_enabled(opts)
  local os_type, err = os_utils.get_os_type()
  if err then
    return false
  end

  if os_type == "windows" or os_type == "wsl" then
    return opts.windows and opts.windows.enabled
  elseif os_type == "macos" then
    return opts.macos and opts.macos.enabled and opts.macos.default_im ~= nil
  elseif os_type == "linux" then
    return opts.linux
      and opts.linux.enabled
      and opts.linux.default_im ~= nil
      and opts.linux.get_im_command ~= nil
      and opts.linux.set_im_command ~= nil
  end
  return false
end

return M
