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

  if opts.macos and (not opts.macos.default_im or opts.macos.default_im == "") then
    notify.error("'macos.default_im' is required when macos is configured")
    return false
  end

  if opts.linux then
    if not opts.linux.default_im or opts.linux.default_im == "" then
      notify.error("'linux.default_im' is required when linux is configured")
      return false
    end
    -- get_im_command/set_im_command are only required when im-switch CLI is not installed
    local path = require("im-switch.utils.path")
    if vim.fn.executable(path.get_cli_path()) ~= 1 then
      for _, field in ipairs({ "get_im_command", "set_im_command" }) do
        if not opts.linux[field] or #opts.linux[field] == 0 then
          notify.error(
            string.format(
              "'linux.%s' is required when im-switch CLI is not installed",
              field
            )
          )
          return false
        end
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
    return opts.windows ~= nil
  elseif os_type == "macos" then
    return opts.macos ~= nil
  elseif os_type == "linux" then
    return opts.linux ~= nil
  end
  return false
end

return M
