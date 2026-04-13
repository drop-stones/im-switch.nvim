-- path_spec.lua
-- Unit tests for im-switch.utils.path

local path = require("im-switch.utils.path")

describe("im-switch.utils.path", function()
  it("returns the plugin root path when called with no arguments", function()
    local root = path.get_plugin_path()
    assert.is_truthy(root)
    assert.is_true(type(root) == "string")
  end)

  it("joins subpaths correctly", function()
    local bin_path = path.get_plugin_path("bin")
    assert.is_truthy(bin_path)
    assert.is_true(type(bin_path) == "string")
    assert.is_not_nil(bin_path:match("bin$"))
    local exe_path = path.get_plugin_path("bin", "im-switch.exe")
    assert.is_truthy(exe_path)
    assert.is_true(type(exe_path) == "string")
    assert.is_not_nil(exe_path:match("bin/im%-switch%.exe$") or exe_path:match("bin\\im%-switch%.exe$"))
  end)
end)
