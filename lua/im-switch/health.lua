local Path = require("plenary.path")
local notify = require("im-switch.utils.notify")
local options = require("im-switch.options")
local utils = require("im-switch.utils")

---Check if plenary.nvim is installed.
local function check_plenary()
  local ok, _ = pcall(require, "plenary")
  if ok then
    vim.health.ok("plenary.nvim is installed")
  else
    vim.health.error("plenary.nvim is not installed")
  end
end

---Check the current Neovim version.
local function check_nvim_version()
  local version = vim.version()
  local nvim_version = string.format("%d.%d.%d", version.major, version.minor, version.patch)
  if version.major > 0 or version.minor >= 10 then
    vim.health.ok("Neovim version: " .. nvim_version)
  else
    vim.health.warn("Neovim version is outdated: " .. nvim_version .. " (0.10+ recommended)")
  end
end

---Check if a command is executable.
---@param command string
local function check_command_exists(command)
  if vim.fn.executable(command) == 1 then
    vim.health.ok(command .. " is executable")
  else
    vim.health.error(command .. " is not executable")
  end
end

---Check Linux-specific options and commands.
---@param opts table
local function check_linux_config(opts)
  if not opts.linux or not opts.linux.enabled then
    vim.health.warn("Linux plugin is disabled")
    return
  end

  if type(opts.linux.default_im) == "string" and opts.linux.default_im ~= "" then
    vim.health.ok("linux.default_im is set: " .. opts.linux.default_im)
  else
    vim.health.error("linux.default_im is not configured")
  end

  for _, key in ipairs({ "get_im_command", "set_im_command" }) do
    local command_tbl = opts.linux[key]
    if type(command_tbl) == "table" and #command_tbl > 0 then
      vim.health.ok("linux." .. key .. " is set: " .. '"' .. table.concat(command_tbl, " ") .. '"')
      check_command_exists(command_tbl[1])
    else
      vim.health.error("linux." .. key .. " is not configured")
    end
  end
end

---Check macOS-specific options.
---@param opts table
local function check_macos_config(opts)
  if not opts.macos or not opts.macos.enabled then
    vim.health.warn("macOS plugin is disabled")
    return
  end

  if type(opts.macos.default_im) == "string" and opts.macos.default_im ~= "" then
    vim.health.ok("macos.default_im is set: " .. opts.macos.default_im)
  else
    vim.health.error("macos.default_im is not configured")
  end
end

---Check Windows/WSL-specific options.
---@param opts table
local function check_windows_config(opts)
  if not opts.windows or not opts.windows.enabled then
    vim.health.warn("Windows/WSL plugin is disabled")
    return
  end
  vim.health.ok("Windows/WSL plugin is enabled")
end

---Check the installed Cargo version.
local function check_cargo_version()
  local result = utils.system.run_system({ "cargo", "--version" })
  if result.code ~= 0 then
    vim.health.info("Cargo is not installed or not found in PATH")
    return
  end

  local version = result.stdout:match("cargo%s+(%d+%.%d+%.%d+)")
  if version then
    local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")
    major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)
    if major > 1 or (major == 1 and minor >= 75) then
      vim.health.ok("Cargo version: " .. version)
    else
      vim.health.warn("Cargo version is outdated: " .. version .. " (1.75.0+ recommended)")
    end
  else
    vim.health.warn("Cargo is installed but version could not be determined")
  end
end

---Extracts the command name from a given input
---@param command string[]|nil
---@return string|nil
local function get_command(command)
  if type(command) == "table" and #command > 0 then
    return command[1]
  end
  return nil
end

---Check the availability of the im-switch binary.
local function check_binary()
  local os_type, err = utils.os.get_os_type()
  if err then
    notify.error(err)
    return
  end

  if os_type == "linux" then
    local opts = options.get()
    for _, key in ipairs({ "get_im_command", "set_im_command" }) do
      local command = get_command(opts.linux[key])
      if not command then
        vim.health.error("Invalid command format of " .. key)
      else
        check_command_exists(command)
      end
    end
  else
    if os_type ~= "wsl" then
      check_cargo_version()
    end

    local ext = utils.path.get_executable_extension()
    local exe_path = Path:new(utils.path.get_plugin_path("bin", "im-switch" .. ext))
    if exe_path:exists() then
      vim.health.ok("im-switch" .. ext .. " is installed correctly")
    else
      vim.health.error("im-switch" .. ext .. " is not installed correctly")
    end
  end
end

---Check and report plugin status based on OS-specific options.
local function check_os_options()
  local os_type, err = utils.os.get_os_type()
  if err then
    notify.error(err)
    return
  end

  local opts = options.get()
  if os_type == "linux" then
    check_linux_config(opts)
  elseif os_type == "macos" then
    check_macos_config(opts)
  elseif os_type == "windows" or os_type == "wsl" then
    check_windows_config(opts)
  else
    vim.health.warn("Unknown OS: " .. tostring(os_type))
  end
end

return {
  check = function()
    vim.health.start("im-switch.nvim")
    check_plenary()
    check_nvim_version()
    check_os_options()
    check_binary()
  end,
}
