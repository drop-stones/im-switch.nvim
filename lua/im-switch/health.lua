local build = require("im-switch.build")
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

---Format a version tuple as "0.2.0".
---@param version number[]
---@return string
local function format_version(version)
  return table.concat(version, ".")
end

---Report the version of the installed im-switch CLI.
---`build.setup()` no longer runs the CLI, so this is the only place where the
---recorded version is compared against the binary actually installed.
local function check_cli_version()
  local cli_path = utils.path.get_cli_path()
  if vim.fn.executable(cli_path) ~= 1 then
    -- A missing CLI is already reported by the platform check.
    return
  end

  local version = build.read_cli_version()
  if not version then
    vim.health.error("Failed to read the im-switch CLI version: " .. cli_path)
    return
  end

  local advice = { "Run ':lua require(\"im-switch.build\").reinstall()' to install it again" }
  if not build.version_gte(version, build.REQUIRED_VERSION) then
    vim.health.error(
      string.format(
        "im-switch CLI %s is older than required %s",
        format_version(version),
        format_version(build.REQUIRED_VERSION)
      ),
      advice
    )
    return
  end

  local recorded = build.read_installed_version()
  if not recorded then
    vim.health.warn(
      "im-switch CLI " .. format_version(version) .. " is installed but its version is not recorded",
      advice
    )
  elseif not vim.deep_equal(recorded, version) then
    vim.health.warn(
      string.format(
        "Recorded version %s does not match the installed im-switch CLI %s",
        format_version(recorded),
        format_version(version)
      ),
      advice
    )
  else
    vim.health.ok("im-switch CLI " .. format_version(version) .. " at " .. cli_path)
  end
end

---Check for deprecated config options.
local function check_deprecated_options()
  local opts = options.get()
  local deprecated = { "default_im_events", "save_im_state_events", "restore_im_events" }
  local found = false
  for _, key in ipairs(deprecated) do
    if opts[key] ~= nil then
      vim.health.warn(
        "'" .. key .. "' is deprecated",
        { "Event options have been removed. Use 'mode = \"restore\"' (default) or 'mode = \"fixed\"' instead." }
      )
      found = true
    end
  end
  if not found then
    vim.health.ok("No deprecated options found")
  end
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
    check_cli_version()

    vim.health.start("im-switch.nvim: migration")
    check_deprecated_options()
    check_migration()
  end,
}
