---Run a system command and return the result.
---@param cmd string[] Command to run
---@param opts? table Options for vim.system (e.g. cwd, env, etc.)
---@return table result { code, stdout, stderr }
local function run_system(cmd, opts)
  return vim
    .system(cmd, vim.tbl_extend("force", { text = true }, opts or { cwd = require("im-switch.utils.path").get_plugin_path() }))
    :wait()
end

---Check if a command is available in PATH (cross-platform)
---@param cmd string
---@return boolean
local function has_command(cmd)
  return vim.fn.executable(cmd) == 1
end

return {
  run_system = run_system,
  has_command = has_command,
}
