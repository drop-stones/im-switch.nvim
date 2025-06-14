local build = require("im-switch.build")
local os_utils = require("im-switch.utils.os")
local path = require("im-switch.utils.path")

describe("integration: im-switch.build.setup", function()
  local orig_has_cargo = build.has_cargo
  local os_type = os_utils.get_os_type()
  local bin_dir = path.get_plugin_path("bin")
  local bin_path = path.get_plugin_path("bin", "im-switch" .. path.get_executable_extension())

  after_each(function()
    build.has_cargo = orig_has_cargo
    if vim.fn.isdirectory(bin_dir) == 1 then
      vim.fn.delete(bin_dir, "rf")
    end
  end)

  it("should build with cargo if available", function()
    ---@diagnostic disable-next-line: duplicate-set-field
    build.has_cargo = function()
      return true
    end
    build.setup()
    if os_type == "windows" or os_type == "wsl" or os_type == "macos" then
      assert.is_true(vim.fn.filereadable(bin_path) == 1)
    else
      assert.is_true(vim.fn.filereadable(bin_path) == 0)
    end
  end)

  it("should download prebuilt binary if cargo is not available", function()
    ---@diagnostic disable-next-line: duplicate-set-field
    build.has_cargo = function()
      return false
    end
    build.setup()
    if os_type == "windows" or os_type == "wsl" or os_type == "macos" then
      assert.is_true(vim.fn.filereadable(bin_path) == 1)
    else
      assert.is_true(vim.fn.filereadable(bin_path) == 0)
    end
  end)
end)
