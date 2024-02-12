local utils = require("utils")

local M = {}

local default_opts = {
	set_default_im_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
	set_previous_im_events = { "InsertEnter" },
}

local function initialize_opts(opts)
	if opts.set_default_im_events == nil then
		opts.set_default_im_events = default_opts.set_default_im_events
	end

	if opts.set_previous_im_events == nil then
		opts.set_previous_im_events = default_opts.set_previous_im_events
	end

	return opts
end

function M.setup(opts)
	-- Initialize options
	opts = initialize_opts(opts)

	local os = utils.get_os()

	-- Check options for mac
	if (os == "mac") and (opts.mac.default_im == nil) then
		return
	end

	-- Check options for linux
	if (os == "linux") and (opts.linux.switch_to_default_im_command == nil) then
		return
	end

	-- Setup autocommand functions
	local group_id = vim.api.nvim_create_augroup("im-switch", { clear = true })
	vim.api.nvim_create_autocmd(opts.set_default_im_events, {
		callback = function()
			utils.ime_off(opts)
		end,
		group = group_id,
	})
end

return M
