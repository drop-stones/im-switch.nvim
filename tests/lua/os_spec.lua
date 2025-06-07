--[[
os_spec.lua
Unit tests for im-switch.utils.os.get_os_type.
Uses table-driven tests to verify OS detection logic and error handling.
Ensures cache is cleared between tests to avoid false positives.
]]

local os_utils = require("im-switch.utils.os")

describe("im-switch.utils.os.get_os_type (table-driven)", function()
  local original_jit
  local original_vim_loop_os_uname

  local test_cases = {
    {
      desc = "detects windows by jit.os",
      jit_os = "windows",
      uname = { sysname = "Windows", release = "10.0.0" },
      expected = "windows",
      err = nil,
    },
    {
      desc = "detects macos by jit.os",
      jit_os = "osx",
      uname = { sysname = "Darwin", release = "22.0.0" },
      expected = "macos",
      err = nil,
    },
    {
      desc = "detects wsl by release",
      jit_os = "linux",
      uname = { sysname = "Linux", release = "4.4.0-19041-Microsoft" },
      expected = "wsl",
      err = nil,
    },
    {
      desc = "detects linux by jit.os",
      jit_os = "linux",
      uname = { sysname = "Linux", release = "5.15.0" },
      expected = "linux",
      err = nil,
    },
    {
      desc = "returns error for unknown jit.os",
      jit_os = "plan9",
      uname = { sysname = "Plan9", release = "1.0.0" },
      expected = nil,
      err = "Unsupported OS",
    },
  }

  before_each(function()
    original_jit = jit
    original_vim_loop_os_uname = vim.loop.os_uname
  end)

  after_each(function()
    _G.jit = original_jit
    ---@diagnostic disable-next-line: inject-field
    vim.loop.os_uname = original_vim_loop_os_uname
    os_utils.clear_os_type_cache()
  end)

  for _, case in ipairs(test_cases) do
    it(case.desc, function()
      ---@diagnostic disable-next-line: assign-type-mismatch, missing-fields
      _G.jit = { os = case.jit_os }
      ---@diagnostic disable-next-line: inject-field
      vim.loop.os_uname = function()
        return case.uname
      end
      local os_type, err = os_utils.get_os_type()
      assert.are.equal(os_type, case.expected)
      if case.err and err then
        assert.is_string(err)
        assert.is_true(err:find(case.err, 1, true) ~= nil)
      else
        assert.is_nil(err)
      end
    end)
  end
end)
