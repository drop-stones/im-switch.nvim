--[[
build_spec.lua
Unit tests for im-switch.build.
Tests target triple detection and version parsing/comparison.
]]

local build = require("im-switch.build")
local os_utils = require("im-switch.utils.os")

describe("im-switch.build", function()
  local original_get_os_type

  before_each(function()
    original_get_os_type = os_utils.get_os_type
  end)

  after_each(function()
    os_utils.get_os_type = original_get_os_type
  end)

  describe("get_target_triple", function()
    local test_cases = {
      { os_type = "windows", expected_suffix = "-pc-windows-msvc" },
      { os_type = "wsl", expected_suffix = "-pc-windows-msvc" },
      { os_type = "macos", expected_suffix = "-apple-darwin" },
      { os_type = "linux", expected_suffix = "-unknown-linux-musl" },
    }

    for _, case in ipairs(test_cases) do
      it("returns correct suffix for " .. case.os_type, function()
        ---@diagnostic disable-next-line: duplicate-set-field
        os_utils.get_os_type = function()
          return case.os_type
        end
        local triple, err = build.get_target_triple()
        assert.is_nil(err)
        assert.is_truthy(triple)
        assert.is_true(triple:find(case.expected_suffix, 1, true) ~= nil)
      end)
    end
  end)

  describe("parse_version", function()
    it("parses 'im-switch 0.1.0'", function()
      assert.are.same({ 0, 1, 0 }, build.parse_version("im-switch 0.1.0"))
    end)

    it("parses '1.2.3'", function()
      assert.are.same({ 1, 2, 3 }, build.parse_version("1.2.3"))
    end)

    it("returns nil for invalid input", function()
      assert.is_nil(build.parse_version("invalid"))
    end)
  end)

  describe("version_gte", function()
    it("returns true for equal versions", function()
      assert.is_true(build.version_gte({ 0, 1, 0 }, { 0, 1, 0 }))
    end)

    it("returns true for greater major", function()
      assert.is_true(build.version_gte({ 1, 0, 0 }, { 0, 1, 0 }))
    end)

    it("returns true for greater minor", function()
      assert.is_true(build.version_gte({ 0, 2, 0 }, { 0, 1, 0 }))
    end)

    it("returns true for greater patch", function()
      assert.is_true(build.version_gte({ 0, 1, 1 }, { 0, 1, 0 }))
    end)

    it("returns false for lesser version", function()
      assert.is_false(build.version_gte({ 0, 0, 9 }, { 0, 1, 0 }))
    end)
  end)
end)
