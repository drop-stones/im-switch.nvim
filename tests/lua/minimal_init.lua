--[[
minimal_init.lua
Test bootstrap file for setting up the test environment.
Ensures plenary.nvim is installed and added to runtimepath for all tests.
]]

-- Get the plugin root directory
local info = debug.getinfo(1, "S")
local script_path = info.source:sub(2)
local plugin_root = vim.fn.fnamemodify(script_path, ":h:h:h")

-- Set plenary.nvim path to the parent of the plugin root (i.e., plugin_root/..)
local plenary_path = vim.fn.fnamemodify(plugin_root, ":h") .. "/plenary.nvim"

-- Install plenary.nvim if not present
if vim.fn.isdirectory(plenary_path) == 0 then
  print("Installing plenary.nvim for testing...")
  vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/nvim-lua/plenary.nvim", plenary_path })
end

-- Prepend plenary.nvim to runtimepath
vim.opt.runtimepath:prepend(plenary_path)
