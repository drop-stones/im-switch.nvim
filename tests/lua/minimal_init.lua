--[[
minimal_init.lua
Test bootstrap file for setting up the test environment.
]]

-- Get the plugin root directory
local info = debug.getinfo(1, "S")
local script_path = info.source:sub(2)
local plugin_root = vim.fn.fnamemodify(script_path, ":h:h:h")

-- Prepend plugin root to runtimepath
vim.opt.runtimepath:prepend(plugin_root)
