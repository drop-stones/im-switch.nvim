#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"

-- Pin to a specific commit for reproducibility
local lazy_bootstrap_url =
  "https://raw.githubusercontent.com/folke/lazy.nvim/306a05526ada86a7b30af95c5cc81ffba93fef97/bootstrap.lua"
local bootstrap = vim.fn.system({ "curl", "-fsSL", lazy_bootstrap_url })
if vim.v.shell_error ~= 0 or not bootstrap or bootstrap == "" then
  error("Failed to download lazy.nvim bootstrap from: " .. lazy_bootstrap_url, 0)
end
local bootstrap_fn, load_err = load(bootstrap, "bootstrap.lua")
if not bootstrap_fn then
  error("Failed to load lazy.nvim bootstrap: " .. tostring(load_err), 0)
end
bootstrap_fn()

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
local MiniTest = require("mini.test")
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

MiniTest.run()
