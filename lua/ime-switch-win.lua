local M = {}

local Path = require("plenary.path")

local function is_supported()
	if vim.fn.has("win32") == 1 or vim.fn.has("wsl") == 1 then
		return true
	else
		return false
	end
end

local function ime_off()
	if Path:new(vim.g["ime-switch-win#executable"]):exists() then
		local output = vim.fn.system({ vim.g["ime-switch-win#executable"], "off" })
	end
end

function M.setup()
	if not is_supported() then
		return
	end

	-- Setup autocommand functions
	local events = { "BufWinEnter", "BufWinLeave", "InsertEnter", "InsertLeave" }
	local group_id = vim.api.nvim_create_augroup("ime-switch-win", { clear = true })
	vim.api.nvim_create_autocmd(events, {
		callback = ime_off,
		group = group_id,
	})
end

return M
