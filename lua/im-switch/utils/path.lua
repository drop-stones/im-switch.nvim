local notify = require("im-switch.utils.notify")
local os_utils = require("im-switch.utils.os")
local system = require("im-switch.utils.system")

---@type string?
local cached_plugin_root_path = nil

---Get the root path of the plugin using git, or fallback to parent directory
---@return string
local function get_plugin_root_path()
  if cached_plugin_root_path then
    return cached_plugin_root_path
  end

  local this_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
  local result = system.run_system({ "git", "rev-parse", "--show-toplevel" }, { cwd = this_dir })

  if result.code ~= 0 then
    -- Fallback: this file is at lua/im-switch/utils/path.lua, so root is 3 levels up
    local fallback = vim.fn.fnamemodify(this_dir, ":h:h:h")
    notify.error("Git command failed in directory: " .. this_dir)
    notify.error("Error: " .. result.stderr)
    notify.warn("Falling back to: " .. fallback)
    cached_plugin_root_path = fallback
    return cached_plugin_root_path
  end

  cached_plugin_root_path = vim.trim(result.stdout)
  return cached_plugin_root_path
end

local M = {}

---Get the plugin root path or a subpath under it
---@param ... string  -- subpaths under root
---@return string
function M.get_plugin_path(...)
  local root = get_plugin_root_path()
  local args = { ... }
  if #args == 0 then
    return root
  end
  return vim.fs.joinpath(root, unpack(args))
end

---Get the install directory for the im-switch CLI binary.
---@return string
function M.get_install_dir()
  local os_type = os_utils.get_os_type()
  if os_type == "windows" then
    local localappdata = os.getenv("LOCALAPPDATA")
    if localappdata then
      return vim.fs.joinpath(localappdata, "im-switch.nvim")
    end
  end
  local home = os.getenv("HOME") or os.getenv("USERPROFILE") or "~"
  return vim.fs.joinpath(home, ".local", "share", "im-switch.nvim")
end

---Get the full path to the im-switch CLI binary.
---@return string
function M.get_cli_path()
  local os_type = os_utils.get_os_type()
  local dir = M.get_install_dir()
  if os_type == "wsl" or os_type == "windows" then
    return vim.fs.joinpath(dir, "im-switch.exe")
  end
  return vim.fs.joinpath(dir, "im-switch")
end

return M
