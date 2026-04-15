local notify = require("im-switch.utils.notify")
local path = require("im-switch.utils.path")
local platforms = require("im-switch.platforms")
local system = require("im-switch.utils.system")

local RELEASE_TAG = "v0.1.1"
local DOWNLOAD_URL = "https://github.com/drop-stones/im-switch/releases/download/" .. RELEASE_TAG .. "/im-switch-%s.tar.gz"
local REQUIRED_VERSION = { 0, 1, 1 }

local M = {}

---Get the CPU identifier for the current architecture.
---@return string?, string?
local function get_cpu()
  local arch = jit and jit.arch:lower() or ""
  if arch == "x64" or arch == "x86_64" then
    return "x86_64"
  elseif arch == "arm64" or arch == "aarch64" then
    return "aarch64"
  end
  return nil, "Unsupported architecture: " .. arch
end

---Get the Rust target triple for the current platform.
---@return string?, string?
function M.get_target_triple()
  local cpu, cpu_err = get_cpu()
  if cpu_err then
    return nil, cpu_err
  end

  local platform, plat_err = platforms.get_platform()
  if plat_err then
    return nil, plat_err
  end

  return platform.target_triple(cpu)
end

---Parse a semantic version string (e.g., "im-switch 0.1.0") into a table.
---@param version_str string
---@return number[]?
function M.parse_version(version_str)
  local major, minor, patch = version_str:match("(%d+)%.(%d+)%.(%d+)")
  if major then
    return { tonumber(major), tonumber(minor), tonumber(patch) }
  end
  return nil
end

---Compare two version tuples. Returns true if `a` >= `b`.
---@param a number[]
---@param b number[]
---@return boolean
function M.version_gte(a, b)
  for i = 1, 3 do
    if a[i] > b[i] then
      return true
    elseif a[i] < b[i] then
      return false
    end
  end
  return true
end

---Check if the installed CLI meets the required version.
---@return boolean
function M.is_version_satisfied()
  local cli_path = path.get_cli_path()
  if vim.fn.executable(cli_path) ~= 1 then
    return false
  end

  local result = system.run_system({ cli_path, "--version" })
  if result.code ~= 0 then
    return false
  end

  local version = M.parse_version(vim.trim(result.stdout))
  if not version then
    return false
  end

  return M.version_gte(version, REQUIRED_VERSION)
end

---Install the im-switch CLI binary from GitHub Releases.
function M.setup()
  if M.is_version_satisfied() then
    return
  end

  local platform, plat_err = platforms.get_platform()
  if plat_err then
    notify.error("Failed to detect platform: " .. plat_err)
    return
  end

  local target, err = M.get_target_triple()
  if err then
    notify.error("Failed to detect target: " .. err)
    return
  end

  local install_dir = path.get_install_dir()
  local cli_path = path.get_cli_path()
  local url = string.format(DOWNLOAD_URL, target)
  local archive_path = vim.fs.joinpath(install_dir, "im-switch.tar.gz")

  -- Preflight check for required tools
  for _, tool in ipairs({ "curl", "tar" }) do
    if vim.fn.executable(tool) ~= 1 then
      notify.error(tool .. " is required but not found in PATH")
      return
    end
  end

  -- Create install directory
  vim.fn.mkdir(install_dir, "p")

  -- Download
  notify.info("Downloading im-switch CLI from " .. url)
  local result = system.run_system({ "curl", "-fSL", "-o", archive_path, url })
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

  -- Platform-specific post-install (e.g., chmod +x on Unix)
  platform.post_install(cli_path)

  -- Clean up archive
  os.remove(archive_path)

  notify.info("Successfully installed im-switch CLI to " .. cli_path)
end

return M
