local Path = require("plenary.path")

if vim.g["ime-switch-win"] ~= nil then
	return
end
vim.g["ime-switch-win"] = 1

-- Executable path settings
vim.g["ime-switch-win#executable"] =
		Path:new(vim.fn.expand("<sfile>:h:h")):joinpath("/target/release/ime-switch-win.exe"):absolute()

require("ime-switch-win").setup()
