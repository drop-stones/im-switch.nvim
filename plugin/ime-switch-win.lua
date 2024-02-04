if vim.g["ime-switch-win"] ~= nil then
	return
end
vim.g["ime-switch-win"] = 1

require("ime-switch-win").setup()
