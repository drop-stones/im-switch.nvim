-- Run cargo in installation
local utils = require("im-switch.utils")

local M = {}

function M.build()
  if utils.need_cargo_build() then
    -- if os is darwin or windows, build im-switch
    vim.fn.system({ "cargo", "build", "--release", "--manifest-path", utils.get_cargo_toml_path() })
  end
end

M.build()

return M
