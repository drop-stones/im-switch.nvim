local Path = require("plenary.path")

if vim.g["ime-switch-win"] ~= nil then
	return
end
vim.g["ime-switch-win"] = 1

-- Plugin root directory path
vim.g["ime-switch-win#root"] = Path:new(vim.fn.expand("<sfile>:h:h")):absolute()

-- Cargo.toml path
vim.g["ime-switch-win#cargo"] = Path:new(vim.g["ime-switch-win#root"]):joinpath("Cargo.toml"):absolute()

-- Executable path settings
vim.g["ime-switch-win#executable"] =
		Path:new(vim.g["ime-switch-win#root"]):joinpath("target/release/ime-switch-win.exe"):absolute()
vim.g["ime-switch-win#bin"] = Path:new(vim.g["ime-switch-win#root"]):joinpath("bin/ime-switch-win.exe"):absolute()

require("ime-switch-win").setup()
