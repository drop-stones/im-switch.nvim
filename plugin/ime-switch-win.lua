if vim.g.loaded_ime_switch == 1 then
	return
end
vim.g.loaded_ime_switch = 1

require("ime-switch-win").setup()
