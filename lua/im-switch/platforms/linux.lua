local path = require("im-switch.utils.path")

local M = {}

M.opts_key = "linux"

---Cached result of whether the installed im-switch CLI binary exists.
---@type boolean?
local cli_exists_cache = nil

---Check if the im-switch CLI binary exists at the install location (cached).
---@return boolean
local function is_cli_installed()
  if cli_exists_cache == nil then
    cli_exists_cache = vim.fn.executable(path.get_cli_path()) == 1
  end
  return cli_exists_cache
end

---Check if user-configured custom commands are set.
---@param opts table
---@return boolean
local function has_custom_commands(opts)
  return opts.linux.get_im_command
    and #opts.linux.get_im_command > 0
    and opts.linux.set_im_command
    and #opts.linux.set_im_command > 0
end

---Reset the CLI existence cache. Used in tests.
function M._reset_cache()
  cli_exists_cache = nil
end

---@param action "get"|"set"
---@param im_value? string
---@param opts table
---@return string[]?, string?
function M.get_im_command(action, im_value, opts)
  -- User-configured commands take priority
  if has_custom_commands(opts) then
    if action == "get" then
      return opts.linux.get_im_command
    elseif action == "set" then
      local command = vim.deepcopy(opts.linux.set_im_command)
      table.insert(command, im_value)
      return command
    end
    return nil, "Unsupported action for Linux: " .. tostring(action)
  end

  -- Fall back to im-switch CLI
  if is_cli_installed() then
    local cli = path.get_cli_path()
    if action == "get" then
      return { cli, "get" }
    elseif action == "set" then
      return { cli, "set", im_value }
    end
    return nil, "Unsupported action for Linux: " .. tostring(action)
  end

  return nil, "No im-switch CLI installed and no custom commands configured for Linux"
end

---@param opts table
---@return string
function M.default_im_value(opts)
  return opts.linux.default_im
end

---@param opts table
---@return boolean
function M.validate(opts)
  if not opts.linux then
    return true
  end
  local notify = require("im-switch.utils.notify")
  if not opts.linux.default_im or opts.linux.default_im == "" then
    notify.error("'linux.default_im' is required when linux is configured")
    return false
  end
  -- get_im_command/set_im_command are only required when im-switch CLI is not installed
  if not is_cli_installed() and not has_custom_commands(opts) then
    notify.error("'linux.get_im_command' and 'linux.set_im_command' are required when im-switch CLI is not installed")
    return false
  end
  return true
end

---@param opts table
function M.check_health(opts)
  if not opts.linux then
    vim.health.warn("Linux plugin is not configured")
    return
  end

  if type(opts.linux.default_im) == "string" and opts.linux.default_im ~= "" then
    vim.health.ok("linux.default_im is set: " .. opts.linux.default_im)
  else
    vim.health.error("linux.default_im is not configured")
  end

  local cli_path = path.get_cli_path()
  if vim.fn.executable(cli_path) == 1 then
    vim.health.ok("im-switch CLI is installed at " .. cli_path)
    if has_custom_commands(opts) then
      vim.health.ok("Custom commands are configured and take priority over CLI")
    end
  else
    if has_custom_commands(opts) then
      vim.health.ok("Using custom commands (im-switch CLI is not installed)")
      for _, key in ipairs({ "get_im_command", "set_im_command" }) do
        local cmd = opts.linux[key]
        vim.health.ok("linux." .. key .. " is set: " .. '"' .. table.concat(cmd, " ") .. '"')
        if vim.fn.executable(cmd[1]) == 1 then
          vim.health.ok(cmd[1] .. " is executable")
        else
          vim.health.error(cmd[1] .. " is not executable")
        end
      end
    else
      vim.health.error("im-switch CLI is not installed and no custom commands configured")
    end
  end
end

---@param cpu string
---@return string
function M.target_triple(cpu)
  return cpu .. "-unknown-linux-musl"
end

---@param cli_path string
function M.post_install(cli_path)
  local system = require("im-switch.utils.system")
  local result = system.run_system({ "chmod", "+x", cli_path })
  if result.code ~= 0 then
    require("im-switch.utils.notify").error("Failed to set executable permissions: " .. result.stderr)
  end
end

return M
