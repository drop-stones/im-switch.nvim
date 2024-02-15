local ok = vim.health.report_ok
local warn = vim.health.report_warn
local error = vim.health.report_error

local utils = require("im-switch.utils")

local M = {}

function M.check()
  vim.health.start("im-switch.nvim")

  if utils.need_cargo_build() then
    if vim.fn.executable("cargo") == 1 then
      ok("Cargo installed")

      if utils.get_built_executable_path():exists() then
        ok("Executable built correctly")
      else
        error("Executable built incorrectly")
      end
    else
      warn("Cargo not installed")
    end
  end
end

return M
