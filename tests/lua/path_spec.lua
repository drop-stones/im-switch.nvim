--[[
path_spec.lua
Unit tests for im-switch.utils.path utility functions.
Verifies correct path resolution, existence checks, and distinction between built/prebuilt paths.
]]

local Path = require("plenary.path")
local path_utils = require("im-switch.utils.path")

describe("im-switch.utils.path", function()
  it("get_plugin_root_path returns a valid path", function()
    local root = path_utils.get_plugin_root_path()
    assert.is_string(root)
    assert.is_true(Path:new(root):exists())
  end)

  it("get_built_executable_path returns a Path object with absolute path", function()
    local built_path = path_utils.get_built_executable_path()
    assert.is_true(built_path:is_path())
    assert.is_string(built_path:absolute())
    assert.is_true(#built_path:absolute() > 0)
  end)

  it("get_prebuilt_executable_path returns a non-empty string path", function()
    local prebuilt_path = path_utils.get_prebuilt_executable_path()
    assert.is_string(prebuilt_path)
    assert.is_true(#prebuilt_path > 0)
  end)

  it("get_executable_path returns a non-empty string path", function()
    local exec_path = path_utils.get_executable_path()
    assert.is_string(exec_path)
    assert.is_true(#exec_path > 0)
  end)

  it("get_built_executable_path and get_prebuilt_executable_path are different", function()
    local built = path_utils.get_built_executable_path()
    local prebuilt = path_utils.get_prebuilt_executable_path()
    assert.is_true(built:absolute() ~= prebuilt)
  end)

  it("get_executable_path returns either built or prebuilt path", function()
    local exec = path_utils.get_executable_path()
    local built = path_utils.get_built_executable_path():absolute()
    local prebuilt = path_utils.get_prebuilt_executable_path()
    assert.is_true(exec == built or exec == prebuilt)
    assert.is_true(Path:new(exec):exists())
  end)
end)
