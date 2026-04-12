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
    if im_value == "enabled" then
      return { cli, "ime", "enable" }
    else
      return { cli, "ime", "disable" }
    end
  end
  return nil, "Unsupported action for Windows/WSL: " .. tostring(action)
end

---@param _opts table
---@return string
function M.default_im_value(_opts)
  return "disabled"
end

---@param opts table
---@return boolean
function M.validate(opts)
  -- No additional validation needed for Windows
  return opts.windows ~= nil
end

---@param opts table
function M.check_health(opts)
  if not opts.windows then
    vim.health.warn("Windows/WSL plugin is not configured")
    return
  end
  vim.health.ok("Windows/WSL plugin is enabled")

  local cli_path = path.get_cli_path()
  if vim.fn.executable(cli_path) == 1 then
    vim.health.ok("im-switch CLI is installed at " .. cli_path)
  else
    vim.health.error("im-switch CLI is not installed at " .. cli_path .. " (run :Lazy build im-switch.nvim)")
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
