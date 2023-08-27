-- Run cargo in installation

local M = {}

local Path = require("plenary.path")

function M.build()
  local output = vim.fn.system({ "cargo", "build", "--release", "--manifest-path", vim.g["ime-switch-win#cargo"] })
  if vim.v.shell_error != 0 then
    vim.fn.system({ "chmod", "+x", vim.g["ime-switch-win#bin"] })
  end
end

M.build()

return M
