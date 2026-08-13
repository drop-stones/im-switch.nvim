--[[
build_spec.lua
Unit tests for im-switch.build.
Tests target triple detection, version parsing/comparison and the recorded
version of the installed CLI.
]]

local build = require("im-switch.build")
local os_utils = require("im-switch.utils.os")
local path = require("im-switch.utils.path")

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

  describe("installed version file", function()
    local original_get_install_dir
    local original_read_cli_version
    local install_dir

    ---Write `content` to the version file of the fake install directory.
    ---@param content string
    local function write_version_file(content)
      local file = assert(io.open(vim.fs.joinpath(install_dir, "version"), "w"))
      file:write(content)
      file:close()
    end

    ---Create a fake, executable CLI binary reporting `version` (defaults to the
    ---version this plugin requires).
    ---@param version? string
    local function create_fake_cli(version)
      local cli_path = path.get_cli_path()
      local file = assert(io.open(cli_path, "w"))
      file:write("#!/bin/sh\necho 'im-switch " .. (version or table.concat(build.REQUIRED_VERSION, ".")) .. "'\n")
      file:close()
      vim.fn.setfperm(cli_path, "rwxr-xr-x")
    end

    before_each(function()
      install_dir = vim.fn.tempname()
      vim.fn.mkdir(install_dir, "p")
      original_get_install_dir = path.get_install_dir
      original_read_cli_version = build.read_cli_version
      ---@diagnostic disable-next-line: duplicate-set-field
      path.get_install_dir = function()
        return install_dir
      end
      -- Keep the download plan deterministic (a single binary named "im-switch")
      ---@diagnostic disable-next-line: duplicate-set-field
      os_utils.get_os_type = function()
        return "linux"
      end
    end)

    after_each(function()
      path.get_install_dir = original_get_install_dir
      build.read_cli_version = original_read_cli_version
      vim.fn.delete(install_dir, "rf")
    end)

    it("read_installed_version returns nil when the file does not exist", function()
      assert.is_nil(build.read_installed_version())
    end)

    it("read_installed_version parses the recorded version", function()
      write_version_file("v1.2.3")
      assert.are.same({ 1, 2, 3 }, build.read_installed_version())
    end)

    it("write_installed_version records the given version", function()
      build.write_installed_version({ 1, 2, 3 })
      assert.are.same({ 1, 2, 3 }, build.read_installed_version())
    end)

    it("is_up_to_date returns false when no version is recorded", function()
      create_fake_cli()
      assert.is_false(build.is_up_to_date())
    end)

    it("is_up_to_date returns false when the recorded version is too old", function()
      create_fake_cli()
      write_version_file("v0.0.1")
      assert.is_false(build.is_up_to_date())
    end)

    it("is_up_to_date returns false when the binary is missing", function()
      build.write_installed_version(build.REQUIRED_VERSION)
      assert.is_false(build.is_up_to_date())
    end)

    it("is_up_to_date returns true when the recorded version and the binary are present", function()
      create_fake_cli()
      build.write_installed_version(build.REQUIRED_VERSION)
      assert.is_true(build.is_up_to_date())
    end)

    it("read_cli_version returns nil when the CLI is missing", function()
      assert.is_nil(build.read_cli_version())
    end)

    it("read_cli_version returns the version reported by the CLI", function()
      create_fake_cli("1.2.3")
      assert.are.same({ 1, 2, 3 }, build.read_cli_version())
    end)

    it("reinstall records the version reported by the CLI", function()
      create_fake_cli()
      write_version_file("v0.0.1")
      -- Stub the CLI call so a failure to run the fake binary cannot fall
      -- through to a real download.
      ---@diagnostic disable-next-line: duplicate-set-field
      build.read_cli_version = function()
        return { 99, 0, 0 }
      end
      build.reinstall()
      assert.are.same({ 99, 0, 0 }, build.read_installed_version())
    end)
  end)
end)
