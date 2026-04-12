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

  local cli_path = utils.path.get_cli_path()
  if vim.fn.executable(cli_path) == 1 then
    vim.health.ok("im-switch CLI is installed; linux.get_im_command/set_im_command are not required")
  else
    for _, key in ipairs({ "get_im_command", "set_im_command" }) do
      local command_tbl = opts.linux[key]
      if type(command_tbl) == "table" and #command_tbl > 0 then
        vim.health.ok("linux." .. key .. " is set: " .. '"' .. table.concat(command_tbl, " ") .. '"')
        check_command_exists(command_tbl[1])
      else
        vim.health.error("linux." .. key .. " is not configured and im-switch CLI is not installed")
      end
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

---Check the availability of the im-switch CLI binary.
local function check_binary()
  local os_type, err = utils.os.get_os_type()
  if err then
    notify.error(err)
    return
  end

  local cli_path = utils.path.get_cli_path()

  if os_type == "linux" then
    if vim.fn.executable(cli_path) == 1 then
      vim.health.ok("im-switch CLI is installed at " .. cli_path)
    else
      vim.health.warn("im-switch CLI is not installed; using user-configured commands as fallback")
      local opts = options.get()
      for _, key in ipairs({ "get_im_command", "set_im_command" }) do
        local command_tbl = opts.linux[key]
        if type(command_tbl) == "table" and #command_tbl > 0 then
          check_command_exists(command_tbl[1])
        else
          vim.health.error("linux." .. key .. " is not configured")
        end
      end
    end
  else
    if vim.fn.executable(cli_path) == 1 then
      vim.health.ok("im-switch CLI is installed at " .. cli_path)
    else
      vim.health.error("im-switch CLI is not installed at " .. cli_path .. " (run :Lazy build im-switch.nvim)")
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

---Check for deprecated options and stale artifacts from older versions.
local function check_deprecations()
  local opts = options.get()

  -- Check for stale bin/ directory from the old embedded-Rust build
  local old_bin_dir = utils.path.get_plugin_path("bin")
  if vim.fn.isdirectory(old_bin_dir) == 1 then
    vim.health.warn(
      "Stale 'bin/' directory found: " .. old_bin_dir,
      { "The CLI is now installed to " .. utils.path.get_install_dir(), "You can safely delete: " .. old_bin_dir }
    )
  else
    vim.health.ok("No stale artifacts from previous versions")
  end

  -- Check for deprecated 'enabled' option
  local deprecated_platforms = {}
  for _, platform in ipairs({ "windows", "macos", "linux" }) do
    if opts[platform] and opts[platform].enabled ~= nil then
      table.insert(deprecated_platforms, platform .. ".enabled")
    end
  end
  if #deprecated_platforms > 0 then
    vim.health.warn(
      "Deprecated option(s): " .. table.concat(deprecated_platforms, ", "),
      { "The 'enabled' option will be removed in a future release", "Remove 'enabled' from your config and rely on 'default_im' to activate each platform" }
    )
  else
    vim.health.ok("No deprecated options detected")
  end
end

return {
  check = function()
    vim.health.start("im-switch.nvim")
    check_plenary()
    check_nvim_version()
    check_os_options()
    check_binary()

    vim.health.start("im-switch.nvim: migration")
    check_deprecations()
  end,
}
