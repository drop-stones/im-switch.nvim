local M = {}

---Detect the current operating system
---@return string
function M.get_os_type()
  if vim.fn.has("wsl") == 1 then
    return "wsl"
  elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    return "windows"
  elseif vim.fn.has("mac") == 1 then
    return "macos"
  elseif vim.fn.has("linux") == 1 then
    return "linux"
  else
    vim.notify("Unsupported OS", vim.log.levels.ERROR)
    return "unsupported"
  end
end

---Check if cargo build is required based on the OS
---@return boolean
function M.should_build_with_cargo()
  local os = M.get_os_type()
  return (os == "macos") or (os == "windows")
end

return M
