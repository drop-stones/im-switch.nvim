local im_command = require("im-switch.utils.im_command")
local os_utils = require("im-switch.utils.os")
local path = require("im-switch.utils.path")

local original_get_os_type = os_utils.get_os_type
local original_get_executable_path = path.get_executable_path

local dummy_opts = {
  macos = { default_im = "com.apple.keylayout.US" },
  linux = {
    default_im = "mozc",
    get_im_command = { "echo", "get-im" },
    set_im_command = { "echo", "set-im" },
  },
  windows = {},
}

describe("im-switch.utils.im_command.get_im_command (table-driven)", function()
  after_each(function()
    os_utils.get_os_type = original_get_os_type
    path.get_executable_path = original_get_executable_path
  end)

  local test_cases = {
    -- Windows
    {
      desc = "windows get",
      os_type = "windows",
      action = "get",
      opts = dummy_opts,
      im_value = nil,
      exe_path = "C:\\im-switch.exe",
      expected = { "C:\\im-switch.exe", "--get" },
      err = nil,
    },
    {
      desc = "windows set with im_value 'on'",
      os_type = "windows",
      action = "set",
      opts = dummy_opts,
      im_value = "on",
      exe_path = "C:\\im-switch.exe",
      expected = { "C:\\im-switch.exe", "--enable" },
      err = nil,
    },
    {
      desc = "windows set with im_value 'off'",
      os_type = "windows",
      action = "set",
      opts = dummy_opts,
      im_value = "off",
      exe_path = "C:\\im-switch.exe",
      expected = { "C:\\im-switch.exe", "--disable" },
      err = nil,
    },
    {
      desc = "windows set with default im_value",
      os_type = "windows",
      action = "set",
      opts = dummy_opts,
      im_value = nil,
      exe_path = "C:\\im-switch.exe",
      expected = { "C:\\im-switch.exe", "--disable" },
      err = nil,
    },
    {
      desc = "windows invalid action",
      os_type = "windows",
      action = "invalid",
      opts = dummy_opts,
      im_value = nil,
      exe_path = "C:\\im-switch.exe",
      expected = nil,
      err = "Unsupported action for Windows/WSL: invalid",
    },
    -- WSL
    {
      desc = "wsl get",
      os_type = "wsl",
      action = "get",
      opts = dummy_opts,
      im_value = nil,
      exe_path = "/mnt/c/im-switch.exe",
      expected = { "/mnt/c/im-switch.exe", "--get" },
      err = nil,
    },
    {
      desc = "wsl set with im_value 'on'",
      os_type = "wsl",
      action = "set",
      opts = dummy_opts,
      im_value = "on",
      exe_path = "/mnt/c/im-switch.exe",
      expected = { "/mnt/c/im-switch.exe", "--enable" },
      err = nil,
    },
    {
      desc = "wsl set with im_value 'off'",
      os_type = "wsl",
      action = "set",
      opts = dummy_opts,
      im_value = "off",
      exe_path = "/mnt/c/im-switch.exe",
      expected = { "/mnt/c/im-switch.exe", "--disable" },
      err = nil,
    },
    {
      desc = "wsl set with default im_value",
      os_type = "wsl",
      action = "set",
      opts = dummy_opts,
      im_value = nil,
      exe_path = "/mnt/c/im-switch.exe",
      expected = { "/mnt/c/im-switch.exe", "--disable" },
      err = nil,
    },
    {
      desc = "wsl invalid action",
      os_type = "wsl",
      action = "invalid",
      opts = dummy_opts,
      im_value = nil,
      exe_path = "/mnt/c/im-switch.exe",
      expected = nil,
      err = "Unsupported action for Windows/WSL: invalid",
    },
    -- macOS
    {
      desc = "macos get",
      os_type = "macos",
      action = "get",
      opts = dummy_opts,
      im_value = nil,
      exe_path = "/usr/local/bin/im-switch",
      expected = { "/usr/local/bin/im-switch", "--get" },
      err = nil,
    },
    {
      desc = "macos set with im_value",
      os_type = "macos",
      action = "set",
      opts = dummy_opts,
      im_value = "com.apple.keylayout.US",
      exe_path = "/usr/local/bin/im-switch",
      expected = { "/usr/local/bin/im-switch", "--set", "com.apple.keylayout.US" },
      err = nil,
    },
    {
      desc = "macos set with default im_value",
      os_type = "macos",
      action = "set",
      opts = dummy_opts,
      im_value = nil,
      exe_path = "/usr/local/bin/im-switch",
      expected = { "/usr/local/bin/im-switch", "--set", "com.apple.keylayout.US" },
      err = nil,
    },
    {
      desc = "macos invalid action",
      os_type = "macos",
      action = "invalid",
      opts = dummy_opts,
      im_value = nil,
      exe_path = "/usr/local/bin/im-switch",
      expected = nil,
      err = "Unsupported action for macOS: invalid",
    },
    -- Linux
    {
      desc = "linux get",
      os_type = "linux",
      action = "get",
      opts = dummy_opts,
      im_value = nil,
      expected = { "echo", "get-im" },
      err = nil,
    },
    {
      desc = "linux set with im_value",
      os_type = "linux",
      action = "set",
      opts = dummy_opts,
      im_value = "mozc",
      expected = { "echo", "set-im", "mozc" },
      err = nil,
    },
    {
      desc = "linux set with default im_value",
      os_type = "linux",
      action = "set",
      opts = dummy_opts,
      im_value = nil,
      expected = { "echo", "set-im", "mozc" },
      err = nil,
    },
    {
      desc = "linux invalid action",
      os_type = "linux",
      action = "invalid",
      opts = dummy_opts,
      im_value = nil,
      expected = nil,
      err = "Unsupported action for Linux: invalid",
    },
    -- Unsupported OS
    {
      desc = "unsupported OS",
      os_type = "plan9",
      action = "get",
      opts = dummy_opts,
      im_value = nil,
      expected = nil,
      err = "Unsupported OS: plan9",
    },
  }

  for _, case in ipairs(test_cases) do
    it(case.desc, function()
      ---@diagnostic disable-next-line: duplicate-set-field
      os_utils.get_os_type = function()
        return case.os_type
      end
      if case.exe_path then
        ---@diagnostic disable-next-line: duplicate-set-field
        path.get_executable_path = function()
          return case.exe_path
        end
      end
      local cmd, err = im_command.get_im_command(case.action, case.opts, case.im_value)
      assert.are.same(cmd, case.expected)
      if case.err then
        assert.is_string(err)
        assert.is_true(err:find(case.err, 1, true) ~= nil)
      else
        assert.is_nil(err)
      end
    end)
  end
end)
