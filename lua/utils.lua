local M = {}

function M.get_os()
	if vim.fn.has("mac") == 1 then
		return "mac"
	elseif vim.fn.has("linux") == 1 then
		return "linux"
	elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
		return "windows"
	elseif vim.fn.has("wsl") == 1 then
		return "wsl"
	else
		print("Unsupported OS")
		os.exit(1)
	end
end

return M
