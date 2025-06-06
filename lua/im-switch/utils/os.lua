local M = {}

---Get the current OS type as a string
---@return "windows"|"wsl"|"macos"|"linux"|nil, string?
function M.get_os_type()
  local jit_os = (jit and jit.os:lower()) or ""
  local uname = vim.loop.os_uname().sysname:lower()
  local release = vim.loop.os_uname().release:lower() or ""

  if jit_os == "windows" or uname:find("windows") then
    return "windows"
  elseif (jit_os == "linux" or uname:find("linux")) and release:find("microsoft") then
    return "wsl"
  elseif jit_os == "osx" or uname:find("darwin") then
    return "macos"
  elseif jit_os == "linux" or uname:find("linux") then
    return "linux"
  end
  return nil, "Unsupported OS: jit=" .. tostring(jit_os) .. ", uname=" .. tostring(uname)
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
