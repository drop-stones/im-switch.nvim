local path = require("im-switch.utils.path")

local M = {}

M.opts_key = "macos"

---@param action "get"|"set"
---@param im_value? string
---@param _opts table
---@return string[]?, string?
function M.get_im_command(action, im_value, _opts)
  local cli = path.get_cli_path()
  if action == "get" then
    return { cli, "get" }
  elseif action == "set" then
    return { cli, "set", im_value }
  end
  return nil, "Unsupported action for macOS: " .. tostring(action)
end

---@param opts table
---@return string
function M.default_im_value(opts)
  return opts.macos.default_im
end

---@param opts table
---@return boolean
function M.validate(opts)
  if not opts.macos then
    return true
  end
  if not opts.macos.default_im or opts.macos.default_im == "" then
    require("im-switch.utils.notify").error("'macos.default_im' is required when macos is configured")
    return false
  end
  return true
end

---@param opts table
function M.check_health(opts)
  if not opts.macos then
    vim.health.warn("macOS plugin is not configured")
    return
  end

  if type(opts.macos.default_im) == "string" and opts.macos.default_im ~= "" then
    vim.health.ok("macos.default_im is set: " .. opts.macos.default_im)
  else
    vim.health.error("macos.default_im is not configured")
  end

  local cli_path = path.get_cli_path()
  if vim.fn.executable(cli_path) == 1 then
    vim.health.ok("im-switch CLI is installed at " .. cli_path)
  else
    vim.health.error("im-switch CLI is not installed at " .. cli_path .. " (rebuild or reinstall the plugin with your plugin manager)")
  end
end

---@param cpu string
---@return string
function M.target_triple(cpu)
  return cpu .. "-apple-darwin"
end

---@param cli_path string
function M.post_install(cli_path)
  local system = require("im-switch.utils.system")
  local result = system.run_system({ "chmod", "+x", cli_path })
  if result.code ~= 0 then
    require("im-switch.utils.notify").error("Failed to set executable permissions: " .. result.stderr)
  end
end

return M
