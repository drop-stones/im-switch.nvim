local utils = require("utils")

local M = {}

function M.setup(opts)
	if not utils.is_supported() then
		return
	end

	-- Setup autocommand functions
	local events = { "InsertEnter", "InsertLeave", "CmdlineEnter", "CmdlineLeave" }
	local group_id = vim.api.nvim_create_augroup("ime-switch", { clear = true })
	vim.api.nvim_create_autocmd(events, {
		callback = function()
			utils.ime_off(opts)
		end,
		group = group_id,
	})
end

return M
