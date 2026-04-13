--[[
options_spec.lua
Unit tests for im-switch.options: validation, plugin activation, and setup.
]]

local options = require("im-switch.options")
local os_utils = require("im-switch.utils.os")
local im_command = require("im-switch.utils.im_command")

describe("im-switch.options", function()
  local original_get_os_type

  before_each(function()
    original_get_os_type = os_utils.get_os_type
    im_command._reset_cache()
  end)

  after_each(function()
    os_utils.get_os_type = original_get_os_type
  end)

  describe("validate_options", function()
    local test_cases = {
      -- macOS
      {
        desc = "macOS: valid config with default_im",
        os_type = "macos",
        opts = { macos = { default_im = "com.apple.keylayout.ABC" } },
        expected = true,
      },
      {
        desc = "macOS: missing default_im",
        os_type = "macos",
        opts = { macos = {} },
        expected = false,
      },
      {
        desc = "macOS: empty default_im",
        os_type = "macos",
        opts = { macos = { default_im = "" } },
        expected = false,
      },
      {
        desc = "macOS: no macos table (not configured)",
        os_type = "macos",
        opts = {},
        expected = true,
      },
      -- Windows (always valid, no config needed)
      {
        desc = "Windows: no config",
        os_type = "windows",
        opts = {},
        expected = true,
      },
      -- Linux
      {
        desc = "Linux: valid config with default_im and custom commands",
        os_type = "linux",
        opts = {
          linux = {
            default_im = "keyboard-us",
            get_im_command = { "fcitx5-remote", "-n" },
            set_im_command = { "fcitx5-remote", "-s" },
          },
        },
        expected = true,
      },
      {
        desc = "Linux: missing default_im",
        os_type = "linux",
        opts = { linux = {} },
        expected = false,
      },
      {
        desc = "Linux: no linux table (not configured)",
        os_type = "linux",
        opts = {},
        expected = true,
      },
      -- Invalid mode
      {
        desc = "invalid mode",
        os_type = "macos",
        opts = { mode = "typo" },
        expected = false,
      },
      {
        desc = "valid mode: fixed",
        os_type = "macos",
        opts = { mode = "fixed" },
        expected = true,
      },
      {
        desc = "valid mode: restore",
        os_type = "macos",
        opts = { mode = "restore" },
        expected = true,
      },
      -- Non-table input
      {
        desc = "non-table input",
        os_type = "linux",
        opts = "invalid",
        expected = false,
      },
    }

    for _, case in ipairs(test_cases) do
      it(case.desc, function()
        ---@diagnostic disable-next-line: duplicate-set-field
        os_utils.get_os_type = function()
          return case.os_type
        end
        assert.equals(case.expected, options.validate_options(case.opts))
      end)
    end
  end)

  describe("is_plugin_enabled", function()
    local test_cases = {
      {
        desc = "enabled when platform table present",
        os_type = "macos",
        opts = { macos = { default_im = "com.apple.keylayout.ABC" } },
        expected = true,
      },
      {
        desc = "disabled when platform table absent",
        os_type = "macos",
        opts = { linux = { default_im = "keyboard-us" } },
        expected = false,
      },
      {
        desc = "always enabled for windows (no config needed)",
        os_type = "windows",
        opts = {},
        expected = true,
      },
      {
        desc = "disabled for unsupported OS",
        os_type = "plan9",
        opts = { macos = {}, windows = {}, linux = {} },
        expected = false,
      },
    }

    for _, case in ipairs(test_cases) do
      it(case.desc, function()
        ---@diagnostic disable-next-line: duplicate-set-field
        os_utils.get_os_type = function()
          return case.os_type
        end
        assert.equals(case.expected, options.is_plugin_enabled(case.opts))
      end)
    end
  end)

  describe("setup", function()
    it("merges user opts with defaults", function()
      options.setup({ macos = { default_im = "com.apple.keylayout.ABC" } })
      local opts = options.get()
      assert.equals("com.apple.keylayout.ABC", opts.macos.default_im)
      assert.equals("restore", opts.mode)
    end)

    it("allows setting fixed mode", function()
      options.setup({ mode = "fixed" })
      local opts = options.get()
      assert.equals("fixed", opts.mode)
    end)
  end)
end)
