local platforms = require("im-switch.platforms")

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
    require("im-switch.utils.notify").error("Options must be a table")
    return false
  end

  local platform = platforms.get_platform()
  if not platform then
    return true
  end

  return platform.validate(opts)
end

---Check if the plugin should be enabled for the current OS and options.
---@param opts table
---@return boolean
function M.is_plugin_enabled(opts)
  local platform = platforms.get_platform()
  if not platform then
    return false
  end
  return opts[platform.opts_key] ~= nil
end

return M
