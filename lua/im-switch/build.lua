local os_utils = require("im-switch.utils.os")
local path = require("im-switch.utils.path")
local rust = require("im-switch.utils.rust")
local system = require("im-switch.utils.system")

local M = {}

---Get the Rust target triple for the current environment
---@return string
local function get_target_triple()
  local os_type, err = os_utils.get_os_type()
  local arch = jit and jit.arch or "x64"
  if err then
    error(err)
  end

  if (os_type == "windows") or (os_type == "wsl") then
    if arch == "x64" then
      return "x86_64-pc-windows-msvc"
    else
      error("Unsupported architecture for windows: " .. arch)
    end
  elseif os_type == "macos" then
    if arch == "x64" then
      return "x86_64-apple-darwin"
    elseif arch == "arm64" then
      return "aarch64-apple-darwin"
    else
      error("Unsupported architecture for macOS: " .. arch)
    end
  end
  error("Unsupported OS type: " .. os_type)
end

---Get the nearest git tag for the current commit (HEAD)
---@return string
local function get_release_version()
  local result = system.run_system({ "git", "describe", "--tags", "--abbrev=0" })
  if result.code ~= 0 or not result.stdout or #result.stdout == 0 then
    error("Could not determine release version (git tag)")
  end
  return vim.trim(result.stdout)
end

---Check if cargo is available in PATH
---@return boolean
function M.has_cargo()
  return system.has_command("cargo")
end

---Build im-switch using cargo and copy the binary to bin/
function M.build_with_cargo()
  path.ensure_directory_exists("bin")
  local ext = path.get_executable_extension()
  local bin_path = path.get_plugin_path("bin", "im-switch" .. ext)
  local target_path = path.get_plugin_path("target", "release", "im-switch" .. ext)

  -- Build
  local build_result = system.run_system({ "cargo", "build", "--release" })
  if build_result.code ~= 0 then
    error("cargo build failed: " .. (build_result.stderr or ""))
  end

  -- Copy
  local ok, err = vim.loop.fs_copyfile(target_path, bin_path)
  if not ok then
    error("Failed to copy built binary to bin/: " .. target_path .. " - " .. (err or "unknown error"))
  end
end

---Download and extract prebuilt im-switch binary to bin/
function M.install_prebuilt_binary()
  local version = get_release_version()
  local triple = get_target_triple()
  local bin_dir = path.ensure_directory_exists("bin")
  local bin_path = path.get_plugin_path("bin", "im-switch" .. path.get_executable_extension())
  local asset_name = string.format("im-switch-%s.zip", triple)
  local url =
    string.format("https://github.com/drop-stones/im-switch.nvim/releases/download/%s/%s", version, asset_name)
  local tmp_zip = path.get_plugin_path("bin", asset_name)

  local os_type, err = os_utils.get_os_type()
  if err then
    error(err)
  end

  -- Download
  local download_result = system.run_system({ "curl", "-fsSL", "-o", tmp_zip, url })
  if download_result.code ~= 0 then
    error("Failed to download prebuilt binary: " .. url .. " - " .. (download_result.stderr or ""))
  end

  -- Unzip
  local unzip_result
  if os_type == "windows" then
    unzip_result = system.run_system({
      "powershell.exe",
      "-NoProfile",
      "-Command",
      "Expand-Archive",
      "-Path",
      tmp_zip,
      "-DestinationPath",
      bin_dir,
      "-Force",
    })
  else
    unzip_result = system.run_system({ "unzip", "-o", tmp_zip, "-d", bin_dir })
  end
  if unzip_result.code ~= 0 then
    error("Failed to unzip prebuilt binary: " .. tmp_zip .. " - " .. (unzip_result.stderr or ""))
  end

  local ok, rm_err = os.remove(tmp_zip)
  if not ok then
    vim.notify("Failed to remove temporary zip file: " .. tmp_zip .. " - " .. (rm_err or ""), vim.log.levels.WARN)
  end

  -- Set executable permission for non-Windows systems
  if os_type ~= "windows" then
    local chmod_result = system.run_system({ "chmod", "+x", bin_path })
    if chmod_result.code ~= 0 then
      error("Failed to set executable permission: " .. bin_path .. " - " .. (chmod_result.stderr or ""))
    end
  end
end

---Main entry: build with cargo or install prebuilt binary
function M.setup()
  local os_type, err = os_utils.get_os_type()
  if err then
    error(err)
  end

  if (os_type == "windows") or (os_type == "macos") then
    if rust.check_cargo_version("1.93.0") then
      M.build_with_cargo()
    else
      M.install_prebuilt_binary()
    end
  elseif os_type == "wsl" then
    M.install_prebuilt_binary()
  end
end

return M
