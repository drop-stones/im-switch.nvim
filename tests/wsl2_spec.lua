--[[
wsl2_spec.lua
Unit tests for the WSL2 platform module: the fast-path command (with
self-contained fallback), delegation to Windows when not opted in, the
two-binary download plan, and platform routing.
]]

local wsl2 = require("im-switch.platforms.wsl2")
local path = require("im-switch.utils.path")

describe("im-switch.platforms.wsl2", function()
  local orig = {}

  before_each(function()
    orig.get_cli_path = path.get_cli_path
    orig.get_wsl2_client_path = path.get_wsl2_client_path
    orig.get_wsl2_server_path = path.get_wsl2_server_path
    ---@diagnostic disable: duplicate-set-field
    path.get_cli_path = function()
      return "/d/im-switch.exe"
    end
    path.get_wsl2_client_path = function()
      return "/d/im-switch"
    end
    path.get_wsl2_server_path = function()
      return "/d/im-switch.exe"
    end
    ---@diagnostic enable: duplicate-set-field
  end)

  after_each(function()
    path.get_cli_path = orig.get_cli_path
    path.get_wsl2_client_path = orig.get_wsl2_client_path
    path.get_wsl2_server_path = orig.get_wsl2_server_path
  end)

  it("is always enabled", function()
    assert.is_true(wsl2.always_enabled)
    assert.equals("wsl2", wsl2.opts_key)
  end)

  describe("get_im_command without the opt-in (delegates to Windows)", function()
    it("no wsl2 table -> direct .exe", function()
      local cmd = wsl2.get_im_command("set", "off", {})
      assert.are.same({ "/d/im-switch.exe", "ime", "off" }, cmd)
    end)

    it("wsl2.server = false -> direct .exe", function()
      local cmd = wsl2.get_im_command("get", nil, { wsl2 = { server = false } })
      assert.are.same({ "/d/im-switch.exe", "ime", "get" }, cmd)
    end)
  end)

  describe("get_im_command with the fast path (wsl2.server = true)", function()
    local opts = { wsl2 = { server = true } }

    it("get -> remote with self-contained fallback", function()
      local cmd = wsl2.get_im_command("get", nil, opts)
      assert.equals("sh", cmd[1])
      assert.equals("-c", cmd[2])
      local s = cmd[3]
      assert.is_true(s:find("'/d/im-switch' remote ime get", 1, true) ~= nil)
      assert.is_true(s:find("setsid '/d/im-switch.exe' serve", 1, true) ~= nil)
      assert.is_true(s:find("exec '/d/im-switch.exe' ime get", 1, true) ~= nil)
    end)

    it("set off -> remote with fallback", function()
      local cmd = wsl2.get_im_command("set", "off", opts)
      assert.is_true(cmd[3]:find("remote ime off", 1, true) ~= nil)
      assert.is_true(cmd[3]:find("exec '/d/im-switch.exe' ime off", 1, true) ~= nil)
    end)

    it("set with an invalid value -> error", function()
      local cmd, err = wsl2.get_im_command("set", "enabled", opts)
      assert.is_nil(cmd)
      assert.is_true(err:find("Unknown IME state", 1, true) ~= nil)
    end)

    it("escapes single quotes in the install path", function()
      ---@diagnostic disable: duplicate-set-field
      path.get_wsl2_client_path = function()
        return "/home/o'brien/im-switch"
      end
      path.get_wsl2_server_path = function()
        return "/home/o'brien/im-switch.exe"
      end
      ---@diagnostic enable: duplicate-set-field
      local cmd = wsl2.get_im_command("get", nil, opts)
      local s = cmd[3]
      -- The `'` is closed, escaped, then reopened: '\''
      assert.is_true(s:find("'/home/o'\\''brien/im-switch' remote ime get", 1, true) ~= nil)
      assert.is_true(s:find("exec '/home/o'\\''brien/im-switch.exe' ime get", 1, true) ~= nil)
    end)
  end)

  describe("download_plan", function()
    it("installs the Linux client and the Windows server", function()
      local plan = wsl2.download_plan("x86_64")
      assert.equals(2, #plan)
      assert.equals("x86_64-unknown-linux-musl", plan[1].triple)
      assert.equals("/d/im-switch", plan[1].path)
      assert.equals("x86_64-pc-windows-msvc", plan[2].triple)
      assert.equals("/d/im-switch.exe", plan[2].path)
    end)
  end)

  it("routes os_type 'wsl' to the wsl2 platform", function()
    local os_utils = require("im-switch.utils.os")
    local original = os_utils.get_os_type
    ---@diagnostic disable-next-line: duplicate-set-field
    os_utils.get_os_type = function()
      return "wsl"
    end
    local platform = require("im-switch.platforms").get_platform()
    os_utils.get_os_type = original
    assert.equals("wsl2", platform.opts_key)
  end)
end)
