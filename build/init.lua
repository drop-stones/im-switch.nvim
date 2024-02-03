-- Run cargo in installation
local utils = require("utils")

local M = {}

function M.build()
	local os = utils.get_os()
	if (os == "mac") or (os == "windows") then
		-- if os is darwin or windows, build ime-switch
		vim.fn.system({ "cargo", "build", "--release", "--manifest-path", vim.g["ime-switch-win#cargo"] })
	end
end

M.build()

return M
