local platforms = require("im-switch.platforms")

--- Default plugin options
---@type PluginOptions
local default_opts = {
  mode = "restore",
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

  local valid_modes = { restore = true, fixed = true }
  if opts.mode ~= nil and not valid_modes[opts.mode] then
    require("im-switch.utils.notify").error("Invalid mode: '" .. tostring(opts.mode) .. "' (expected 'restore' or 'fixed')")
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
  -- Windows/WSL: always enabled (no user config needed)
  if platform.opts_key == "windows" then
    return true
  end
  -- macOS/Linux: enabled when platform table is present
  return opts[platform.opts_key] ~= nil
end

return M
