local Path = require("plenary.path")

--==============================================================
-- Local Functions
--==============================================================

--- Detect the current operating system
---@return string
local function detect_os()
  local os_map = {
    wsl = "wsl",
    win32 = "windows",
    win64 = "windows",
    mac = "mac",
    linux = "linux",
  }

  for feature, os_name in pairs(os_map) do
    if vim.fn.has(feature) == 1 then
      return os_name
    end
  end

  vim.api.nvim_err_writeln("Unsupported OS")
  error("Unsupported OS")
end

--- Get the root path of the plugin using git
---@return Path the root path
local function get_plugin_root_path()
  -- stylua: ignore
  local path = debug.getinfo(1, "S").source:sub(2):match("(.*/)") -- path to im-switch.nvim/lua/im-switch/
  local result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true, cwd = path }):wait()

  if result.code ~= 0 then
    vim.api.nvim_err_writeln("Git command failed in directory: " .. script_path())
    vim.api.nvim_err_writeln("Error: " .. result.stderr)
    error("Unable to determine plugin root path")
  end

  local root_path = vim.trim(result.stdout)

  return Path:new(root_path)
end

--- Get the executable file extension based on OS and whether it is prebuilt
---@param is_prebuilt boolean whether the executable is prebuilt
---@return string the appropriate file extension
local function get_executable_extension(is_prebuilt)
  local os = detect_os()
  if (os == "wsl") or (os == "windows") then
    return ".exe"
  elseif os == "mac" then
    if is_prebuilt == true then
      return ".bin"
    end
  end
  return ""
end

--==============================================================
-- Public Functions
--==============================================================

local M = {}

--- Detect the current operating system
---@return string
M.detect_os = detect_os

--- Get the root path of the plugin using git
---@return string the root path
function M.get_plugin_root_path()
  return get_plugin_root_path():absolute()
end

--- Check if cargo build is required based on the OS
--- @return boolean
function M.should_build_with_cargo()
  local os = M.detect_os()
  return (os == "mac") or (os == "windows")
end

--- Get the built executable path in the release directory
---@return Path the absolute path to the built executable
function M.get_built_executable_path()
  return get_plugin_root_path():joinpath("target/release/im-switch" .. get_executable_extension(false))
end

--- Get the prebuilt executable path in bin directory
---@return string the absolute path to the prebuilt executable
function M.get_prebuilt_executable_path()
  return get_plugin_root_path():joinpath("bin/im-switch" .. get_executable_extension(true)):absolute()
end

--- Get the appropriate executable path, checking for prebuilt versions or workarounds for WSL
---@return string the absolute path to the executable
function M.get_executable_path()
  local executable_path = M.get_built_executable_path()
  local prebuilt_executable_path = M.get_prebuilt_executable_path()

  if executable_path:exists() then
    return executable_path:absolute()
  end

  if M.detect_os() == "wsl" then -- FIXME: Workaround for WSL users
    -- Get windows %TEMP% path and convert to WSL path
    local temp_windows_path = vim.trim(vim.system({ "cmd.exe", "/c", "echo %TEMP%" }, { text = true }):wait().stdout)
    local temp_wsl_path = vim.trim(vim.system({ "wslpath", "-au", temp_windows_path }, { text = true }):wait().stdout)

    local executable_path_in_temp = temp_wsl_path .. "/im-switch" .. get_executable_extension(true)
    local path = Path:new(executable_path_in_temp)

    if not path:exists() then
      -- Copy the prebuilt executable to the %TEMP% directory to speed up execution
      local result = vim.system({ "cp", prebuilt_executable_path, temp_wsl_path }):wait()
      if result.code ~= 0 then
        error("Failed to copy prebuilt executable to %TEMP%: " .. result.stderr)
      end
    end

    return executable_path_in_temp
  end

  return prebuilt_executable_path
end

--- Concatenate a list of strings with spaces
---@param list table|string input list or a single string
---@return string the concatenated string
function M.concat(list)
  if type(list) == "string" then
    return list
  elseif type(list) == "table" then
    return table.concat(list, " ")
  else
    error("concat() expected a table or string, but got " .. type(list))
  end
end

--- Split a string to string[]
---@param str string|string[]
---@return string[]
function M.split(str)
  if type(str) == "table" then
    return str
  elseif type(str) == "string" then
    return vim.split(str, " ")
  else
    error("split() expected a string or string[], but got " .. type(str))
  end
end

return M
