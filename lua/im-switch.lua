local utils = require("utils")

local M = {}

function M.setup(opts)
	local os = utils.get_os()

	-- Check options for mac
	if (os == "mac") and (opts.mac.default_im == nil) then
		return
	end

	-- Check options for linux
	if (os == "linux") and (opts.linux.switch_im_command == nil or opts.linux.default_im == nil) then
		return
	end

	-- Setup autocommand functions
	local events = { "InsertEnter", "InsertLeave", "CmdlineEnter", "CmdlineLeave" }
	local group_id = vim.api.nvim_create_augroup("im-switch", { clear = true })
	vim.api.nvim_create_autocmd(events, {
		callback = function()
			utils.ime_off(opts)
		end,
		group = group_id,
	})
end

return M
