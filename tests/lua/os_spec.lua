local os_utils = require("im-switch.utils.os")

local original_jit = jit
local original_vim_loop_os_uname = vim.loop.os_uname

describe("im-switch.utils.os.get_os_type (table-driven)", function()
  after_each(function()
    _G.jit = original_jit
    ---@diagnostic disable-next-line: inject-field
    vim.loop.os_uname = original_vim_loop_os_uname
  end)

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

  for _, case in ipairs(test_cases) do
    it(case.desc, function()
      ---@diagnostic disable-next-line: assign-type-mismatch, missing-fields
      _G.jit = { os = case.jit_os }
      ---@diagnostic disable-next-line: duplicate-set-field, inject-field
      vim.loop.os_uname = function()
        return case.uname
      end
      local os_type, err = os_utils.get_os_type()
      assert.are.equal(os_type, case.expected)
      if case.err then
        assert.is_string(err)
        assert.is_true(err:find(case.err, 1, true) ~= nil)
      else
        assert.is_nil(err)
      end
    end)
  end
end)

describe("im-switch.utils.os.should_build_with_cargo", function()
  local original_get_os_type = os_utils.get_os_type

  after_each(function()
    os_utils.get_os_type = original_get_os_type
  end)

  local cases = {
    { os_type = "macos", expected = true },
    { os_type = "windows", expected = true },
    { os_type = "linux", expected = false },
    { os_type = "wsl", expected = false },
    { os_type = nil, expected = false },
  }

  for _, case in ipairs(cases) do
    it("returns " .. tostring(case.expected) .. " for os_type=" .. tostring(case.os_type), function()
      ---@diagnostic disable-next-line: duplicate-set-field
      os_utils.get_os_type = function()
        return case.os_type
      end
      assert.are.equal(os_utils.should_build_with_cargo(), case.expected)
    end)
  end
end)
