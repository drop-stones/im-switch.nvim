local M = {}

---@type string?
local cached_os_type = nil

---Get the current OS type as a string
---@return "windows"|"wsl"|"macos"|"linux"|nil, string?
function M.get_os_type()
  if cached_os_type then
    return cached_os_type
  end

  local jit_os = (jit and jit.os:lower()) or ""
  local uname = vim.loop.os_uname().sysname:lower()
  local release = vim.loop.os_uname().release:lower() or ""

  if jit_os == "windows" or uname:find("windows") then
    cached_os_type = "windows"
  elseif (jit_os == "linux" or uname:find("linux")) and release:find("microsoft") then
    cached_os_type = "wsl"
  elseif jit_os == "osx" or uname:find("darwin") then
    cached_os_type = "macos"
  elseif jit_os == "linux" or uname:find("linux") then
    cached_os_type = "linux"
  else
    return nil, "Unsupported OS: jit=" .. tostring(jit_os) .. ", uname=" .. tostring(uname)
  end
  return cached_os_type
end

---Clear the cached OS type (for testing or reload).
function M.clear_os_type_cache()
  cached_os_type = nil
end

---Check if cargo build is required based on the OS
---@return boolean
function M.should_build_with_cargo()
  local os_type, err = M.get_os_type()
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end

  return (os_type == "macos") or (os_type == "windows")
end

return M
