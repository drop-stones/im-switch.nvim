local M = {}

local utils = require("utils")
local Path = require("plenary.path")

local function is_supported()
	local os = utils.get_os()
	if os == "windows" or os == "wsl" then
		return true
	end
	return false
end

local function run_ime_switch_win(arg)
	if Path:new(vim.g["ime-switch-win#executable"]):exists() then
		return vim.fn.system({ vim.g["ime-switch-win#executable"], arg })
	else
		return vim.fn.system({ vim.g["ime-switch-win#bin"], arg })
	end
end

local function ime_off()
	run_ime_switch_win("off")
end

function M.setup()
	if not is_supported() then
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
