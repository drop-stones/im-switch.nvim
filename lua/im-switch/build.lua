local notify = require("im-switch.utils.notify")
local os_utils = require("im-switch.utils.os")
local path = require("im-switch.utils.path")
local system = require("im-switch.utils.system")

local DOWNLOAD_URL = "https://github.com/drop-stones/im-switch/releases/latest/download/im-switch-%s.tar.gz"

local M = {}

---Get the Rust target triple for the current platform.
---@return string?, string?
function M.get_target_triple()
  local os_type, err = os_utils.get_os_type()
  if err then
    return nil, err
  end

  local arch = jit and jit.arch:lower() or ""
  local cpu
  if arch == "x64" or arch == "x86_64" then
    cpu = "x86_64"
  elseif arch == "arm64" or arch == "aarch64" then
    cpu = "aarch64"
  else
    return nil, "Unsupported architecture: " .. arch
  end

  if os_type == "windows" or os_type == "wsl" then
    return cpu .. "-pc-windows-msvc"
  elseif os_type == "macos" then
    return cpu .. "-apple-darwin"
  elseif os_type == "linux" then
    return cpu .. "-unknown-linux-musl"
  end

  return nil, "Unsupported OS for download: " .. tostring(os_type)
end

---Install the im-switch CLI binary from GitHub Releases.
function M.setup()
  local target, err = M.get_target_triple()
  if err then
    notify.error("Failed to detect target: " .. err)
    return
  end

  local install_dir = path.get_install_dir()
  local cli_path = path.get_cli_path()
  local url = string.format(DOWNLOAD_URL, target)
  local archive_path = install_dir .. "/im-switch.tar.gz"

  -- Create install directory
  vim.fn.mkdir(install_dir, "p")

  -- Download
  print("im-switch.nvim: Downloading im-switch CLI from " .. url)
  local result = system.run_system({ "curl", "-L", "-o", archive_path, url })
  if result.code ~= 0 then
    notify.error("Failed to download im-switch CLI: " .. result.stderr)
    return
  end

  -- Extract
  result = system.run_system({ "tar", "xzf", archive_path, "-C", install_dir })
  if result.code ~= 0 then
    notify.error("Failed to extract im-switch CLI: " .. result.stderr)
    return
  end

  -- Set executable permissions (Unix only)
  local os_type = os_utils.get_os_type()
  if os_type ~= "windows" then
    result = system.run_system({ "chmod", "+x", cli_path })
    if result.code ~= 0 then
      notify.error("Failed to set executable permissions: " .. result.stderr)
      return
    end
  end

  -- Clean up archive
  os.remove(archive_path)

  print("im-switch.nvim: Successfully installed im-switch CLI to " .. cli_path)
end

return M
