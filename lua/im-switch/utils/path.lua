local Path = require("plenary.path")
local notify = require("im-switch.utils.notify")
local os_utils = require("im-switch.utils.os")
local system = require("im-switch.utils.system")

---@type Path?
local cached_plugin_root_path = nil

---Get the root path of the plugin using git, or fallback to parent directory
---@return Path the root path
local function get_plugin_root_path()
  if cached_plugin_root_path then
    return cached_plugin_root_path
  end

  local path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
  local result = system.run_system({ "git", "rev-parse", "--show-toplevel" }, { cwd = path })

  if result.code ~= 0 then
    local fallback = vim.fn.fnamemodify(path, ":h:h")
    notify.error("Git command failed in directory: " .. path)
    notify.error("Error: " .. result.stderr)
    notify.warn("Falling back to: " .. fallback)
    cached_plugin_root_path = Path:new(fallback)
    return cached_plugin_root_path
  end

  local root_path = vim.trim(result.stdout)
  cached_plugin_root_path = Path:new(root_path)
  return cached_plugin_root_path
end

local M = {}

---Get a Path object for the plugin root or a subpath under it
---@param ... string  -- subpaths under root
---@return string
function M.get_plugin_path(...)
  local root = get_plugin_root_path()
  local args = { ... }
  if #args == 0 then
    return root:absolute()
  else
    return root:joinpath(unpack(args)):absolute()
  end
end

---Get the executable file extension for the current OS
---@return string
function M.get_executable_extension()
  local os_type, err = os_utils.get_os_type()
  if err then
    notify.error(err)
    return ""
  end

  if (os_type == "wsl") or (os_type == "windows") then
    return ".exe"
  else
    return ""
  end
end

---Ensure the given directory exists
---@param ... string
---@return string
function M.ensure_directory_exists(...)
  local dir = M.get_plugin_path(...)
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  return dir
end

return M
