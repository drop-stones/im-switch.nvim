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

describe("im-switch.utils.im_command.get_im_command (table-driven)", function()
  local original_get_os_type
  local original_get_cli_path

  before_each(function()
    original_get_os_type = os_utils.get_os_type
    original_get_cli_path = path.get_cli_path
    im_command._reset_cache()
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
      opts = { windows = {}, macos = {}, linux = {} },
      expected = { "C:\\im-switch.exe", "ime", "get" },
    },
    {
      desc = "windows set with im_value 'enabled'",
      os_type = "windows",
      action = "set",
      im_value = "enabled",
      cli_path = "C:\\im-switch.exe",
      opts = { windows = {}, macos = {}, linux = {} },
      expected = { "C:\\im-switch.exe", "ime", "enable" },
    },
    {
      desc = "windows set with im_value 'disabled'",
      os_type = "windows",
      action = "set",
      im_value = "disabled",
      cli_path = "C:\\im-switch.exe",
      opts = { windows = {}, macos = {}, linux = {} },
      expected = { "C:\\im-switch.exe", "ime", "disable" },
    },
    {
      desc = "windows set with default im_value",
      os_type = "windows",
      action = "set",
      im_value = nil,
      cli_path = "C:\\im-switch.exe",
      opts = { windows = {}, macos = {}, linux = {} },
      expected = { "C:\\im-switch.exe", "ime", "disable" },
    },
    {
      desc = "windows invalid action",
      os_type = "windows",
      action = "invalid",
      im_value = nil,
      cli_path = "C:\\im-switch.exe",
      opts = { windows = {}, macos = {}, linux = {} },
      err = "Unsupported action for Windows/WSL: invalid",
    },
    -- WSL
    {
      desc = "wsl get",
      os_type = "wsl",
      action = "get",
      im_value = nil,
      cli_path = "/mnt/c/im-switch.exe",
      opts = { windows = {}, macos = {}, linux = {} },
      expected = { "/mnt/c/im-switch.exe", "ime", "get" },
    },
    {
      desc = "wsl set with im_value 'enabled'",
      os_type = "wsl",
      action = "set",
      im_value = "enabled",
      cli_path = "/mnt/c/im-switch.exe",
      opts = { windows = {}, macos = {}, linux = {} },
      expected = { "/mnt/c/im-switch.exe", "ime", "enable" },
    },
    {
      desc = "wsl set with im_value 'disabled'",
      os_type = "wsl",
      action = "set",
      im_value = "disabled",
      cli_path = "/mnt/c/im-switch.exe",
      opts = { windows = {}, macos = {}, linux = {} },
      expected = { "/mnt/c/im-switch.exe", "ime", "disable" },
    },
    {
      desc = "wsl set with default im_value",
      os_type = "wsl",
      action = "set",
      im_value = nil,
      cli_path = "/mnt/c/im-switch.exe",
      opts = { windows = {}, macos = {}, linux = {} },
      expected = { "/mnt/c/im-switch.exe", "ime", "disable" },
    },
    {
      desc = "wsl invalid action",
      os_type = "wsl",
      action = "invalid",
      im_value = nil,
      cli_path = "/mnt/c/im-switch.exe",
      opts = { windows = {}, macos = {}, linux = {} },
      err = "Unsupported action for Windows/WSL: invalid",
    },
    -- macOS
    {
      desc = "macos get",
      os_type = "macos",
      action = "get",
      im_value = nil,
      cli_path = "/usr/local/bin/im-switch",
      opts = { macos = { default_im = "com.apple.keylayout.US" }, windows = {}, linux = {} },
      expected = { "/usr/local/bin/im-switch", "get" },
    },
    {
      desc = "macos set with im_value",
      os_type = "macos",
      action = "set",
      im_value = "com.apple.keylayout.US",
      cli_path = "/usr/local/bin/im-switch",
      opts = { macos = { default_im = "com.apple.keylayout.US" }, windows = {}, linux = {} },
      expected = { "/usr/local/bin/im-switch", "set", "com.apple.keylayout.US" },
    },
    {
      desc = "macos set with default im_value",
      os_type = "macos",
      action = "set",
      im_value = nil,
      cli_path = "/usr/local/bin/im-switch",
      opts = { macos = { default_im = "com.apple.keylayout.US" }, windows = {}, linux = {} },
      expected = { "/usr/local/bin/im-switch", "set", "com.apple.keylayout.US" },
    },
    {
      desc = "macos invalid action",
      os_type = "macos",
      action = "invalid",
      im_value = nil,
      cli_path = "/usr/local/bin/im-switch",
      opts = { macos = { default_im = "com.apple.keylayout.US" }, windows = {}, linux = {} },
      err = "Unsupported action for macOS: invalid",
    },
    -- Linux: custom commands configured (takes priority regardless of CLI)
    {
      desc = "linux get (custom commands priority)",
      os_type = "linux",
      action = "get",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = true,
      opts = {
        linux = { default_im = "keyboard-us", get_im_command = { "fcitx5-remote", "-n" }, set_im_command = { "fcitx5-remote", "-s" } },
        windows = {},
        macos = {},
      },
      expected = { "fcitx5-remote", "-n" },
    },
    {
      desc = "linux set with im_value (custom commands priority)",
      os_type = "linux",
      action = "set",
      im_value = "mozc",
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = true,
      opts = {
        linux = { default_im = "keyboard-us", get_im_command = { "fcitx5-remote", "-n" }, set_im_command = { "fcitx5-remote", "-s" } },
        windows = {},
        macos = {},
      },
      expected = { "fcitx5-remote", "-s", "mozc" },
    },
    -- Linux: no custom commands, CLI installed
    {
      desc = "linux get (CLI fallback)",
      os_type = "linux",
      action = "get",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = true,
      opts = { linux = { default_im = "keyboard-us" }, windows = {}, macos = {} },
      expected = { "/home/user/.local/share/im-switch.nvim/im-switch", "get" },
    },
    {
      desc = "linux set with im_value (CLI fallback)",
      os_type = "linux",
      action = "set",
      im_value = "keyboard-us",
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = true,
      opts = { linux = { default_im = "keyboard-us" }, windows = {}, macos = {} },
      expected = { "/home/user/.local/share/im-switch.nvim/im-switch", "set", "keyboard-us" },
    },
    {
      desc = "linux set with default im_value (CLI fallback)",
      os_type = "linux",
      action = "set",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = true,
      opts = { linux = { default_im = "keyboard-us" }, windows = {}, macos = {} },
      expected = { "/home/user/.local/share/im-switch.nvim/im-switch", "set", "keyboard-us" },
    },
    -- Linux: no custom commands, no CLI
    {
      desc = "linux get (no CLI, no custom commands)",
      os_type = "linux",
      action = "get",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = false,
      opts = { linux = { default_im = "keyboard-us" }, windows = {}, macos = {} },
      err = "No im-switch CLI installed and no custom commands configured",
    },
    -- Linux: invalid action
    {
      desc = "linux invalid action (custom commands)",
      os_type = "linux",
      action = "invalid",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      opts = {
        linux = { default_im = "keyboard-us", get_im_command = { "echo", "get" }, set_im_command = { "echo", "set" } },
        windows = {},
        macos = {},
      },
      err = "Unsupported action for Linux: invalid",
    },
    {
      desc = "linux invalid action (CLI fallback)",
      os_type = "linux",
      action = "invalid",
      im_value = nil,
      cli_path = "/home/user/.local/share/im-switch.nvim/im-switch",
      cli_installed = true,
      opts = { linux = { default_im = "keyboard-us" }, windows = {}, macos = {} },
      err = "Unsupported action for Linux: invalid",
    },
    -- Unsupported OS
    {
      desc = "unsupported OS",
      os_type = "plan9",
      action = "get",
      im_value = nil,
      opts = { windows = {}, macos = {}, linux = {} },
      err = "Unsupported OS: plan9",
    },
  }

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
      options.setup(case.opts)

      local original_executable
      if case.cli_installed ~= nil then
        original_executable = vim.fn.executable
        vim.fn.executable = function(cmd)
          if cmd == case.cli_path then
            return case.cli_installed and 1 or 0
          end
          return original_executable(cmd)
        end
      end

      local cmd, err = im_command.get_im_command(case.action, case.im_value)

      if original_executable then
        vim.fn.executable = original_executable
      end

      if case.err then
        assert.is_nil(cmd)
        assert.is_string(err)
        assert.is_true(err:find(case.err, 1, true) ~= nil)
      else
        assert.are.same(case.expected, cmd)
        assert.is_nil(err)
      end
    end)
  end
end)
