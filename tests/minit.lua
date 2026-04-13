#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"), "bootstrap.lua")()

require("lazy.minit").setup({
  spec = {
    {
      "echasnovski/mini.test",
      opts = {
        collect = {
          find_files = function()
            return #_G.arg > 0 and _G.arg or vim.fn.globpath("tests", "**/*_spec.lua", true, true)
          end,
        },
      },
    },
    { dir = vim.uv.cwd() },
  },
})

-- Busted-compatible assert shim built on MiniTest.expect (no luarocks needed)
package.path = package.path .. ";" .. vim.uv.cwd() .. "/tests/?.lua"
local expect = MiniTest.expect
local _assert = assert

local Assert = {
  __call = function(_, ...)
    return _assert(...)
  end,
  same = expect.equality,
  equal = expect.equality,
  equals = expect.equality,
  are = {
    same = expect.equality,
    equal = expect.equality,
  },
  is_not = {
    same = expect.no_equality,
  },
  is_nil = function(a)
    return expect.equality(nil, a)
  end,
  is_not_nil = function(a)
    return expect.no_equality(nil, a)
  end,
  is_true = function(a)
    return expect.equality(true, a)
  end,
  is_false = function(a)
    return expect.equality(false, a)
  end,
  is_truthy = function(a)
    if not a then
      error("Expected truthy value, got " .. tostring(a), 2)
    end
  end,
  is_string = function(a)
    return expect.equality("string", type(a))
  end,
}
Assert.__index = Assert
assert = setmetatable({}, Assert)

require("mini.test").run()
