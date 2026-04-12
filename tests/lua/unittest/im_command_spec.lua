--[[
im_command_spec.lua
Unit tests for im-switch.utils.im_command.get_im_command.
Covers all supported OS types and actions using table-driven tests.
Ensures correct command generation and error handling for each scenario.
]]

local im_command = require("im-switch.utils.im_command")
local options = require("im-switch.options")
local os_utils = require("im-switch.utils.os")
local path = require("im-switch.utils.path")

local dummy_opts = {
  macos = { default_im = "com.apple.keylayout.US" },
  linux = {
    default_im = "keyboard-us",
    get_im_command = { "echo", "get-im" },
    set_im_command = { "echo", "set-im" },
  },
  windows = {},
}

describe("im-switch.utils.im_command.get_im_command (table-driven)", function()
  local original_get_os_type
  local original_get_cli_path

  before_each(function()
    original_get_os_type = os_utils.get_os_type
    original_get_cli_path = path.get_cli_path
    im_command._reset_cache()
    options.setup(dummy_opts)
  end)

  after_each(function()
    os_utils.get_os_type = original_get_os_type
    path.get_cli_path = original_get_cli_path
  end)

  local test_cases = {
    -- Windows
    {
      desc = "windows get",
      os_type = "windows",
      action = "get",
      im_value = nil,
      cli_path = "C:\\im-switch.exe",
      expected = { "C:\\im-switch.exe", "ime", "get" },
      err = nil,
    },
    {
      desc = "windows set with im_value 'enabled'",
      os_type = "windows",
      action = "set",
      im_value = "enabled",
      cli_path = "C:\\im-switch.exe",
      expected = { "C:\\im-switch.exe", "ime", "enable" },
      err = nil,
    },
    {
      desc = "windows set with im_value 'disabled'",
      os_type = "windows",
      action = "set",
      im_value = "disabled",
      cli_path = "C:\\im-switch.exe",
      expected = { "C:\\im-switch.exe", "ime", "disable" },
      err = nil,
    },
    {
      desc = "windows set with default im_value",
      os_type = "windows",
      action = "set",
      im_value = nil,
      cli_path = "C:\\im-switch.exe",
      expected = { "C:\\im-switch.exe", "ime", "disable" },
      err = nil,
    },
    {
      desc = "windows invalid action",
      os_type = "windows",
      action = "invalid",
      im_value = nil,
      cli_path = "C:\\im-switch.exe",
      expected = nil,
      err = "Unsupported action for Windows/WSL: invalid",
    },
    -- WSL
    {
      desc = "wsl get",
      os_type = "wsl",
      action = "get",
      im_value = nil,
      cli_path = "/mnt/c/im-switch.exe",
      expected = { "/mnt/c/im-switch.exe", "ime", "get" },
      err = nil,
    },
    {
      desc = "wsl set with im_value 'enabled'",
      os_type = "wsl",
      action = "set",
      im_value = "enabled",
      cli_path = "/mnt/c/im-switch.exe",
      expected = { "/mnt/c/im-switch.exe", "ime", "enable" },
      err = nil,
    },
    {
      desc = "wsl set with im_value 'disabled'",
      os_type = "wsl",
      action = "set",
      im_value = "disabled",
      cli_path = "/mnt/c/im-switch.exe",
      expected = { "/mnt/c/im-switch.exe", "ime", "disable" },
      err = nil,
    },
    {
      desc = "wsl set with default im_value",
      os_type = "wsl",
      action = "set",
      im_value = nil,
      cli_path = "/mnt/c/im-switch.exe",
      expected = { "/mnt/c/im-switch.exe", "ime", "disable" },
      err = nil,
    },
    {
      desc = "wsl invalid action",
      os_type = "wsl",
      action = "invalid",
      im_value = nil,
      cli_path = "/mnt/c/im-switch.exe",
      expected = nil,
      err = "Unsupported action for Windows/WSL: invalid",
    },
    -- macOS
    {
      desc = "macos get",
      os_type = "macos",
      action = "get",
      im_value = nil,
      cli_path = "/usr/local/bin/im-switch",
      expected = { "/usr/local/bin/im-switch", "get" },
      err = nil,
    },
    {
      desc = "macos set with im_value",
      os_type = "macos",
      action = "set",
      im_value = "com.apple.keylayout.US",
      cli_path = "/usr/local/bin/im-switch",
      expected = { "/usr/local/bin/im-switch", "set", "com.apple.keylayout.US" },
      err = nil,
    },
    {
      desc = "macos set with default im_value",
      os_type = "macos",
      action = "set",
      im_value = nil,
      cli_path = "/usr/local/bin/im-switch",
      expected = { "/usr/local/bin/im-switch", "set", "com.apple.keylayout.US" },
      err = nil,
    },
    {
      desc = "macos invalid action",
      os_type = "macos",
      action = "invalid",
      im_value = nil,
      cli_path = "/usr/local/bin/im-switch",
      expected = nil,
      err = "Unsupported action for macOS: invalid",
    },
    -- Linux with im-switch CLI installed
    {
      desc = "linux get (CLI installed)",
      os_type = "linux",
      action = "get",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = true,
      expected = { "/home/user/.local/share/im-switch.nvim/im-switch", "get" },
      err = nil,
    },
    {
      desc = "linux set with im_value (CLI installed)",
      os_type = "linux",
      action = "set",
      im_value = "keyboard-us",
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = true,
      expected = { "/home/user/.local/share/im-switch.nvim/im-switch", "set", "keyboard-us" },
      err = nil,
    },
    {
      desc = "linux set with default im_value (CLI installed)",
      os_type = "linux",
      action = "set",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = true,
      expected = { "/home/user/.local/share/im-switch.nvim/im-switch", "set", "keyboard-us" },
      err = nil,
    },
    {
      desc = "linux invalid action (CLI installed)",
      os_type = "linux",
      action = "invalid",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = true,
      expected = nil,
      err = "Unsupported action for Linux: invalid",
    },
    -- Linux with im-switch CLI not installed (fallback to user commands)
    {
      desc = "linux get (fallback)",
      os_type = "linux",
      action = "get",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = false,
      expected = { "echo", "get-im" },
      err = nil,
    },
    {
      desc = "linux set with im_value (fallback)",
      os_type = "linux",
      action = "set",
      im_value = "keyboard-us",
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = false,
      expected = { "echo", "set-im", "keyboard-us" },
      err = nil,
    },
    {
      desc = "linux set with default im_value (fallback)",
      os_type = "linux",
      action = "set",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = false,
      expected = { "echo", "set-im", "keyboard-us" },
      err = nil,
    },
    {
      desc = "linux invalid action (fallback)",
      os_type = "linux",
      action = "invalid",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = false,
      expected = nil,
      err = "Unsupported action for Linux: invalid",
    },
    -- Unsupported OS
    {
      desc = "unsupported OS",
      os_type = "plan9",
      action = "get",
      im_value = nil,
      expected = nil,
      err = "Unsupported OS: plan9",
    },
  }

  -- Table-driven test for all OS/action combinations.
  for _, case in ipairs(test_cases) do
    it(case.desc, function()
      ---@diagnostic disable-next-line: duplicate-set-field
      os_utils.get_os_type = function()
        return case.os_type
      end
      if case.cli_path then
        ---@diagnostic disable-next-line: duplicate-set-field
        path.get_cli_path = function()
          return case.cli_path
        end
      end
      if case.cli_installed ~= nil then
        -- Mock vim.fn.executable to control CLI detection
        local original_executable = vim.fn.executable
        vim.fn.executable = function(cmd)
          if cmd == case.cli_path then
            return case.cli_installed and 1 or 0
          end
          return original_executable(cmd)
        end
        local cmd, err = im_command.get_im_command(case.action, case.im_value)
        vim.fn.executable = original_executable
        assert.are.same(cmd, case.expected)
        if case.err and err then
          assert.is_string(err)
          assert.is_true(err:find(case.err, 1, true) ~= nil)
        else
          assert.is_nil(err)
        end
      else
        local cmd, err = im_command.get_im_command(case.action, case.im_value)
        assert.are.same(cmd, case.expected)
        if case.err and err then
          assert.is_string(err)
          assert.is_true(err:find(case.err, 1, true) ~= nil)
        else
          assert.is_nil(err)
        end
      end
    end)
  end
end)
