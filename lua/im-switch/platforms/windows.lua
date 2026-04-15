local path = require("im-switch.utils.path")

local M = {}

M.opts_key = "windows"

---@param action "get"|"set"
---@param im_value? string
---@param _opts table
---@return string[]?, string?
function M.get_im_command(action, im_value, _opts)
  local cli = path.get_cli_path()
  if action == "get" then
    return { cli, "ime", "get" }
  elseif action == "set" then
    if im_value == "on" then
      return { cli, "ime", "on" }
    elseif im_value == "off" then
      return { cli, "ime", "off" }
    else
      return nil, "Unknown IME state: " .. tostring(im_value) .. " (expected 'on' or 'off')"
    end
  end
  return nil, "Unsupported action for Windows/WSL: " .. tostring(action)
end

---@param _opts table
---@return string
function M.default_im_value(_opts)
  return "off"
end

---@param opts table
---@return boolean
function M.validate(opts)
  -- No additional validation needed for Windows
  return true
end

---@param opts table
function M.check_health(opts)
  vim.health.ok("Windows/WSL plugin is enabled (always enabled on this platform)")

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
  return cpu .. "-pc-windows-msvc"
end

---@param _cli_path string
function M.post_install(_cli_path)
  -- No post-install steps needed on Windows
end

return M
