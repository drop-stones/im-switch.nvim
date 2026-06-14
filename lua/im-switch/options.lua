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
    require("im-switch.utils.notify").error(
      "Invalid mode: '" .. tostring(opts.mode) .. "' (expected 'restore' or 'fixed')"
    )
    return false
  end

  -- Platform settings, when present, must be tables. (Guard before
  -- platform.validate, which indexes these and would otherwise throw on a
  -- non-table value such as a number or boolean.)
  for _, key in ipairs({ "macos", "linux", "wsl2" }) do
    if opts[key] ~= nil and type(opts[key]) ~= "table" then
      require("im-switch.utils.notify").error("'" .. key .. "' must be a table")
      return false
    end
  end
  if opts.wsl2 ~= nil and opts.wsl2.server ~= nil and type(opts.wsl2.server) ~= "boolean" then
    require("im-switch.utils.notify").error("'wsl2.server' must be a boolean")
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
  -- Platforms with no required config (Windows/WSL2) are always enabled.
  if platform.always_enabled then
    return true
  end
  -- macOS/Linux: enabled when their settings table is present.
  return opts[platform.opts_key] ~= nil
end

return M
