-- Run cargo in installation

local M = {}

local function GetOsName()
	local uname = vim.loop.os_uname()
	local os = uname.sysname
	if (os == "Linuux") and uname.release:lower():find("microsoft") then
		return "WSL"
	else
		if os:find("Windows") then
			return "Windows"
		end
	end
	return os
end

function M.build()
	local os = GetOsName()
	if (os == "Darwin") or (os == "Windows") then
		-- if os is darwin or windows, build ime-switch
		vim.fn.system({ "cargo", "build", "--release", "--manifest-path", vim.g["ime-switch-win#cargo"] })
	end
end

M.build()

return M
