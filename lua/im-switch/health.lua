local options = require("im-switch.options")
local utils = require("im-switch.utils")

local function check_plenary()
  local ok, _ = pcall(require, "plenary")
  if ok then
    vim.health.ok("plenary.nvim is installed")
  else
    vim.health.error("plenary.nvim is not installed")
  end
end

local function check_nvim_version()
  local version = vim.version()
  local nvim_version = string.format("%d.%d.%d", version.major, version.minor, version.patch)
  if version.major > 0 or version.minor >= 10 then
    vim.health.ok("Neovim version: " .. nvim_version)
  else
    vim.health.warn("Neovim version is outdated: " .. nvim_version .. " (0.10+ recommended)")
  end
end

--- Reports plugin status based on OS-specific options
local function check_os_options()
  local os_type, err = utils.os.get_os_type()
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  local opts = options.get()
  local platform_opts = opts[os_type]
  if os_type == "wsl" then
    platform_opts = opts.windows
  end

  if not platform_opts then
    vim.health.error(os_type .. " options are missing")
    return
  end

  if platform_opts.enabled then
    vim.health.ok("Plugin is enabled")
    if os_type == "macos" or os_type == "linux" then
      if type(platform_opts.default_im) == "string" then
        vim.health.ok("default_im is " .. platform_opts.default_im)
      else
        vim.health.error("default_im is not configured")
      end
    end
    if os_type == "linux" then
      for _, key in ipairs({ "get_im_command", "set_im_command" }) do
        if type(platform_opts[key]) == "table" then
          vim.health.ok(key .. " is " .. '"' .. table.concat(platform_opts[key], " ") .. '"')
        else
          vim.health.error(key .. " is not configured")
        end
      end
    end
  else
    vim.health.ok("Plugin is disabled")
  end
end

local function check_cargo_version()
  local result = utils.system.run_system({ "cargo", "--version" })

  if result.code ~= 0 then
    vim.health.error("Cargo is not installed or not found in PATH")
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

--- Extracts the command name from a given input
---@param command string[]|nil
---@return string|nil
local function get_command(command)
  if type(command) == "table" and #command > 0 then
    return command[1]
  end
  return nil
end

--- Check the availability of the im-switch binary
local function check_binary()
  local os_type, err = utils.os.get_os_type()
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  if utils.os.should_build_with_cargo() and (vim.fn.executable("cargo") == 1) then
    check_cargo_version()

    if utils.path.get_built_executable_path():exists() then
      vim.health.ok("im-switch is built correctly")
    else
      vim.health.error("im-switch is not built correctly")
    end
  elseif os_type == "linux" then
    local commands = {} -- set to store unique command names
    for _, key in ipairs({ "get_im_command", "set_im_command" }) do
      local opts = options.get()
      local command = get_command(opts.linux[key])
      if not command then
        vim.health.error("Invalid command format of " .. key)
      elseif not commands[command] then
        commands[command] = true
        if vim.fn.executable(command) == 0 then
          vim.health.error(command .. " is not executable")
        else
          vim.health.ok(command .. " is executable")
        end
      end
    end
  else
    local arch = jit.arch
    if ((os_type == "windows" or os_type == "wsl") and arch == "x64") or (os_type == "macos" and arch == "arm64") then
      vim.health.ok("Prebuilt binary is used: " .. utils.path.get_prebuilt_executable_path())
    else
      vim.health.error("Prebuilt binary is not supported on this OS/architecture")
    end
  end
end

return {
  check = function()
    vim.health.start("im-switch.nvim")

    check_plenary()
    check_nvim_version()

    if not opts then
      vim.health.error("Plugin options are missing!")
      return
    end

    check_os_options()
    check_binary()
  end,
}
