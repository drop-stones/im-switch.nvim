-- Run cargo in installation

local M = {}

local Path = require("plenary.path")

function M.build()
	-- Make `bin/ime-switch-win.exe` executable
	local add_executable_mode = function()
		vim.fn.system({ "chmod", "+x", vim.g["ime-switch-win#bin"] })
	end

	if vim.fn.executable("cargo") == 1 then
		vim.fn.system({ "cargo", "build", "--release", "--manifest-path", vim.g["ime-switch-win#cargo"] })
		-- if build is failed, use `bin/ime-switch-win.exe` instead
		if vim.v.shell_error ~= 0 then
			add_executable_mode()
		end
	else
		-- if cargo is not available, use `bin/ime-switch-win.exe` instead
		add_executable_mode()
	end
end

M.build()

return M
