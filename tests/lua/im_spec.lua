local im = require("im-switch.im")
local im_command = require("im-switch.utils.im_command")
local options = require("im-switch.options")

describe("im-switch.im", function()
  local original_get_im_command
  local original_vim_system

  before_each(function()
    original_get_im_command = im_command.get_im_command
    original_vim_system = vim.system
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.system = function(_, _)
      return {
        wait = function()
          return { code = 0, stdout = "dummy\n", stderr = "" }
        end,
      }
    end
  end)

  after_each(function()
    im_command.get_im_command = original_get_im_command
    vim.system = original_vim_system
  end)

  describe("set_default_im", function()
    it("calls get_im_command with 'set' and default_im", function()
      local called = false
      ---@diagnostic disable-next-line: duplicate-set-field
      im_command.get_im_command = function(action, im_value)
        called = true
        assert.equals(action, "set")
        assert.equals(im_value, nil)
        return { "echo", "set-im", im_value }, nil
      end
      local opts = {
        macos = { default_im = "dummy" },
        linux = { default_im = "dummy" },
      }
      options.setup(opts)
      local ok = im.set_default_im()
      assert.is_true(called)
      assert.is_true(ok)
    end)
  end)

  describe("restore_im", function()
    it("calls get_im_command with 'set' and restore_im", function()
      local calls = {}
      ---@diagnostic disable-next-line: duplicate-set-field
      im_command.get_im_command = function(action, im_value)
        table.insert(calls, { action = action, im_value = im_value })
        if action == "get" then
          return { "echo", "get-im" }, nil
        elseif action == "set" then
          return { "echo", "set-im", im_value }, nil
        end
      end
      local opts = {
        macos = { restore_im = "dummy" },
        linux = { restore_im = "dummy" },
      }
      options.setup(opts)
      local ok = im.restore_im()
      assert.is_true(ok)
      assert.equals(calls[1].action, "get")
      assert.equals(calls[2].action, "set")
      assert.equals(calls[2].im_value, "dummy")
    end)
  end)
end)
