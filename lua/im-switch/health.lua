local options = require("im-switch.options")
local platforms = require("im-switch.platforms")
local utils = require("im-switch.utils")

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

---Run platform-specific health checks.
local function check_platform()
  local platform, err = platforms.get_platform()
  if err then
    vim.health.error("Failed to detect platform: " .. err)
    return
  end
  if not platform then
    vim.health.warn("Unknown platform")
    return
  end

  local opts = options.get()
  platform.check_health(opts)
end

---Check for stale artifacts from older versions.
local function check_migration()
  local old_bin_dir = utils.path.get_plugin_path("bin")
  if vim.fn.isdirectory(old_bin_dir) == 1 then
    vim.health.warn(
      "Stale 'bin/' directory found: " .. old_bin_dir,
      { "The CLI is now installed to " .. utils.path.get_install_dir(), "You can safely delete: " .. old_bin_dir }
    )
  else
    vim.health.ok("No stale artifacts from previous versions")
  end
end

return {
  check = function()
    vim.health.start("im-switch.nvim")
    check_nvim_version()
    check_platform()

    vim.health.start("im-switch.nvim: migration")
    check_migration()
  end,
}
