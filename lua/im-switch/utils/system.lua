---Run a system command and return the result.
---@param cmd string[] Command to run
---@param opts? table Options for vim.system (e.g. cwd, env, etc.)
---@return table result { code, stdout, stderr }
local function run_system(cmd, opts)
  return vim.system(cmd, vim.tbl_extend("force", { text = true }, opts or {})):wait()
end

return {
  run_system = run_system,
}
