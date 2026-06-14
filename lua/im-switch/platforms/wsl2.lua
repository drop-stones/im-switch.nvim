local linux = require("im-switch.platforms.linux")
local path = require("im-switch.utils.path")
local windows = require("im-switch.platforms.windows")

-- WSL2 inherits the Windows IME behavior and adds an opt-in loopback IPC fast
-- path. Anything not overridden here falls through to the Windows platform.
local M = setmetatable({}, { __index = windows })

M.opts_key = "wsl2"
M.always_enabled = true

---Escape a string for safe embedding inside single quotes in a shell command.
---A literal `'` (a valid character in Unix paths) is rewritten as `'\''`, which
---closes the quote, inserts an escaped quote, then reopens it.
---@param s string
---@return string
local function sh_quote(s)
  return (s:gsub("'", "'\\''"))
end

---@param opts table
---@return boolean
local function fast_path_enabled(opts)
  return opts.wsl2 ~= nil and opts.wsl2.server == true
end

---@param action "get"|"set"
---@param im_value? string
---@param opts table
---@return string[]?, string?
function M.get_im_command(action, im_value, opts)
  -- Without the opt-in, behave exactly like Windows (run im-switch.exe directly).
  if not fast_path_enabled(opts) then
    return windows.get_im_command(action, im_value, opts)
  end

  -- Resolve the `ime` argument.
  local arg
  if action == "get" then
    arg = "get"
  elseif action == "set" then
    if im_value ~= "on" and im_value ~= "off" then
      return nil, "Unknown IME state: " .. tostring(im_value) .. " (expected 'on' or 'off')"
    end
    arg = im_value
  else
    return nil, "Unsupported action for WSL2: " .. tostring(action)
  end

  -- Forward to the loopback daemon via the Linux client. On transport failure
  -- (exit 2 = daemon unreachable) run the Windows server directly and (re)start
  -- the daemon. Self-contained so the generic runner needs no special-casing.
  local client = sh_quote(path.get_wsl2_client_path())
  local server = sh_quote(path.get_wsl2_server_path())
  local script = string.format(
    "'%s' remote ime %s; rc=$?; [ \"$rc\" = 2 ] && { setsid '%s' serve >/dev/null 2>&1 </dev/null & exec '%s' ime %s; }; exit $rc",
    client,
    arg,
    server,
    server,
    arg
  )
  return { "sh", "-c", script }
end

---Binaries to install on WSL2: the native Linux client and the Windows server,
---both into the WSL install dir. (Installed regardless of the fast-path opt-in,
---since the build step runs without access to user options.)
---@param cpu string
---@return table[]
function M.download_plan(cpu)
  return {
    { triple = linux.target_triple(cpu), path = path.get_wsl2_client_path() },
    { triple = windows.target_triple(cpu), path = path.get_wsl2_server_path() },
  }
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
