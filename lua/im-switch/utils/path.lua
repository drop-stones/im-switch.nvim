local Path = require("plenary.path")
local os_utils = require("im-switch.utils.os")

---Get the root path of the plugin using git
---@return Path the root path
local function get_plugin_root_path()
  local path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
  local result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true, cwd = path }):wait()

  if result.code ~= 0 then
    local fallback = vim.fn.fnamemodify(path, ":h:h")
    vim.notify("Git command failed in directory: " .. path, vim.log.levels.ERROR)
    vim.notify("Error: " .. result.stderr, vim.log.levels.ERROR)
    vim.notify("Falling back to: " .. fallback, vim.log.levels.WARN)
    return Path:new(fallback)
  end

  local root_path = vim.trim(result.stdout)
  return Path:new(root_path)
end

---Get the executable file extension based on OS and whether it is prebuilt
---@param is_prebuilt boolean
---@return string
local function get_executable_extension(is_prebuilt)
  local os = os_utils.get_os_type()
  if (os == "wsl") or (os == "windows") then
    return ".exe"
  elseif os == "macos" then
    if is_prebuilt == true then
      return ".bin"
    end
  end
  return ""
end

local M = {}

---Get the root path of the plugin using git
---@return string the root path
function M.get_plugin_root_path()
  return get_plugin_root_path():absolute()
end

---Get the built executable path in the release directory
---@return Path
function M.get_built_executable_path()
  return get_plugin_root_path():joinpath("target/release/im-switch" .. get_executable_extension(false))
end

---Get the prebuilt executable path in bin directory
---@return string
function M.get_prebuilt_executable_path()
  return get_plugin_root_path():joinpath("bin/im-switch" .. get_executable_extension(true)):absolute()
end

---Get the appropriate executable path
---@return string
function M.get_executable_path()
  local executable_path = M.get_built_executable_path()
  local prebuilt_executable_path = M.get_prebuilt_executable_path()

  if executable_path:exists() then
    return executable_path:absolute()
  end

  return prebuilt_executable_path
end

return M
