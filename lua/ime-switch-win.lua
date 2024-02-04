local utils = require("utils")

local M = {}

local function ime_off()
	vim.fn.system({ utils.get_executable_path(), "off" })
end

function M.setup()
	if not utils.is_supported() then
		return
	end

	-- Setup autocommand functions
	local events = { "InsertEnter", "InsertLeave", "CmdlineEnter", "CmdlineLeave" }
	local group_id = vim.api.nvim_create_augroup("ime-switch-win", { clear = true })
	vim.api.nvim_create_autocmd(events, {
		callback = ime_off,
		group = group_id,
	})
end

return M
