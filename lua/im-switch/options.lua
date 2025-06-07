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

---Check if the plugin is enabled and all required settings are properly configured.
---This function is called before initialize_opts(), so opts.windows/opts.macos/opts.linux maybe nil.
---@param user_opts PluginOptions
---@return boolean
function M.is_plugin_configured(user_opts)
  local os_type, err = os_utils.get_os_type()
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end

  if os_type == "wsl" or os_type == "windows" then
    return user_opts.windows and user_opts.windows.enabled
  elseif os_type == "macos" then
    if user_opts.macos and user_opts.macos.enabled and not user_opts.macos.default_im then
      vim.notify("The 'macos.default_im' field must be defined when macos plugin is enabled", vim.log.levels.ERROR)
      return false
    end
    return user_opts.macos and user_opts.macos.enabled
  elseif os_type == "linux" then
    if user_opts.linux and user_opts.linux.enabled then
      local required_fields = { "default_im", "get_im_command", "set_im_command" }
      for _, field in ipairs(required_fields) do
        if not user_opts.linux[field] then
          vim.notify(
            string.format("The 'linux.%s' field must be defined when linux plugin is enabled", field),
            vim.log.levels.ERROR
          )
          return false
        end
      end
      return true
    end
    return false
  else
    vim.notify("Unsupported OS", vim.log.levels.ERROR)
    return false
  end
end

return M
