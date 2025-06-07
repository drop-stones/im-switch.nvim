--[[
path_spec.lua
Unit tests for im-switch.utils.path utility functions.
Table-driven: get_os_type() is mocked for each OS to verify correct behavior.
]]

local Path = require("plenary.path")
local notify = require("im-switch.utils.notify")
local os_utils = require("im-switch.utils.os")
local path_utils = require("im-switch.utils.path")

local original_get_os_type = os_utils.get_os_type
local original_notify_warn = notify.warn

local test_cases = {
  {
    os_type = "linux",
    desc = "returns nil for built/prebuilt/executable path on Linux",
    built_check = function()
      assert.is_nil(path_utils.get_built_executable_path())
    end,
    prebuilt_check = function()
      assert.is_nil(path_utils.get_prebuilt_executable_path())
    end,
    exec_check = function()
      assert.is_nil(path_utils.get_executable_path())
    end,
  },
  {
    os_type = "windows",
    desc = "returns valid paths on Windows",
    built_check = function()
      local built_path = path_utils.get_built_executable_path()
      assert(built_path)
      assert.is_true(built_path:is_path())
      assert.is_string(built_path:absolute())
      assert.is_true(#built_path:absolute() > 0)
    end,
    prebuilt_check = function()
      local prebuilt_path = path_utils.get_prebuilt_executable_path()
      assert.is_string(prebuilt_path)
      assert.is_true(#prebuilt_path > 0)
    end,
    exec_check = function()
      local exec_path = path_utils.get_executable_path()
      assert.is_string(exec_path)
      assert.is_true(#exec_path > 0)
    end,
  },
  {
    os_type = "macos",
    desc = "returns valid paths on macOS",
    built_check = function()
      local built_path = path_utils.get_built_executable_path()
      assert(built_path)
      assert.is_true(built_path:is_path())
      assert.is_string(built_path:absolute())
      assert.is_true(#built_path:absolute() > 0)
    end,
    prebuilt_check = function()
      local prebuilt_path = path_utils.get_prebuilt_executable_path()
      assert.is_string(prebuilt_path)
      assert.is_true(#prebuilt_path > 0)
    end,
    exec_check = function()
      local exec_path = path_utils.get_executable_path()
      assert.is_string(exec_path)
      assert.is_true(#exec_path > 0)
    end,
  },
  {
    os_type = "wsl",
    desc = "returns valid paths on WSL",
    built_check = function()
      local built_path = path_utils.get_built_executable_path()
      assert(built_path)
      assert.is_true(built_path:is_path())
      assert.is_string(built_path:absolute())
      assert.is_true(#built_path:absolute() > 0)
    end,
    prebuilt_check = function()
      local prebuilt_path = path_utils.get_prebuilt_executable_path()
      assert.is_string(prebuilt_path)
      assert.is_true(#prebuilt_path > 0)
    end,
    exec_check = function()
      local exec_path = path_utils.get_executable_path()
      assert.is_string(exec_path)
      assert.is_true(#exec_path > 0)
    end,
  },
}

describe("im-switch.utils.path (table-driven by OS)", function()
  it("get_plugin_root_path returns a valid path", function()
    local root = path_utils.get_plugin_root_path()
    assert.is_string(root)
    assert.is_true(Path:new(root):exists())
  end)

  for _, case in ipairs(test_cases) do
    describe("when os_type is " .. case.os_type, function()
      before_each(function()
        ---@diagnostic disable-next-line: duplicate-set-field
        os_utils.get_os_type = function()
          return case.os_type
        end
        notify.warn = function(_) end -- suppress warnings during test
      end)

      after_each(function()
        os_utils.get_os_type = original_get_os_type
        notify.warn = original_notify_warn
      end)

      it("built executable path: " .. case.desc, case.built_check)
      it("prebuilt executable path: " .. case.desc, case.prebuilt_check)
      it("executable path: " .. case.desc, case.exec_check)
    end)
  end
end)
