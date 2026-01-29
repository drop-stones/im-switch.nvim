local path = require("im-switch.utils.path")
local rust = require("im-switch.utils.rust")
local stub = require("luassert.stub")
local system = require("im-switch.utils.system")

describe("extract_rust_version", function()
  it("extracts version from a valid Cargo.toml", function()
    -- create dummy Cargo.toml
    local tmpfile = "test_Cargo.toml"
    local file = io.open(tmpfile, "w")
    file:write([[
      [package]
      name = "im-switch.nvim"
      version = "0.1.0"
      rust-version = "1.75.0"
    ]])
    file:close()

    -- stub path.get_plugin_path to return our dummy file
    stub(path, "get_plugin_path", function(...)
      return tmpfile
    end)

    -- call the function and check result
    local version, err = rust.extract_rust_version()
    assert.are.equal("1.75.0", version)
    os.remove(tmpfile)
    path.get_plugin_path:revert()
  end)

  it("returns error if Cargo.toml does not exist", function()
    -- dummy stub to return non-existent file
    stub(path, "get_plugin_path", function(...)
      return "non_existent_Cargo.toml"
    end)

    -- call the function and check error
    local version, err = rust.extract_rust_version()
    assert.is_nil(version)
    assert.is_truthy(err)
    path.get_plugin_path:revert()
  end)

  it("returns error if no rust-version", function()
    -- create dummy Cargo.toml without rust-version
    local tmpfile = "no_rust_version_Cargo.toml"
    local file = io.open(tmpfile, "w")
    file:write([[
      [package]
      name = "im-switch.nvim"
      version = "0.1.0"
    ]])
    file:close()

    -- stub path.get_plugin_path to return our dummy file
    stub(path, "get_plugin_path", function(...)
      return tmpfile
    end)

    -- call the function and check error
    local version, err = rust.extract_rust_version()
    assert.is_nil(version)
    assert.is_truthy(err)
    os.remove(tmpfile)
    path.get_plugin_path:revert()
  end)
end)

describe("check_cargo_version", function()
  after_each(function()
    local function safe_revert(mod, method)
      if type(mod[method]) == "table" and mod[method].revert then
        mod[method]:revert()
      end
    end
    safe_revert(system, "run_system")
    safe_revert(system, "has_command")
    safe_revert(rust, "extract_rust_version")
  end)

  it("returns true when cargo version satisfies requirement", function()
    -- stub functions
    stub(system, "has_command", function(cmd)
      return true
    end)
    stub(system, "run_system", function(cmd)
      return { code = 0, stdout = "cargo 1.95.0 (a1b2c3d4e 2026-01-29)", stderr = "" }
    end)
    stub(rust, "extract_rust_version", function()
      return "1.93.0"
    end)

    -- call the function and check result
    local ok, msg = rust.check_cargo_version()
    assert.is_true(ok)
    assert.matches("meets the requirement", msg)
  end)

  it("returns true when cargo versions are exactly equal", function()
    -- stub functions
    stub(system, "has_command", function(cmd)
      return true
    end)
    stub(system, "run_system", function(cmd)
      return { code = 0, stdout = "cargo 1.93.0 (a1b2c3d4e 2026-01-29)", stderr = "" }
    end)
    stub(rust, "extract_rust_version", function()
      return "1.93.0"
    end)

    -- call the function and check result
    local ok, msg = rust.check_cargo_version()
    assert.is_true(ok)
    assert.matches("meets the requirement", msg)
  end)

  it("returns false when cargo version does not satisfy requirement", function()
    -- stub functions
    stub(system, "has_command", function(cmd)
      return true
    end)
    stub(system, "run_system", function(cmd)
      return { code = 0, stdout = "cargo 1.75.0 (a1b2c3d4e 2026-01-29)", stderr = "" }
    end)
    stub(rust, "extract_rust_version", function()
      return "1.93.0"
    end)

    -- call the function and check result
    local ok, msg = rust.check_cargo_version()
    assert.is_false(ok)
    assert.matches("does not meet the requirement", msg)
  end)

  it("returns false if cargo is not found", function()
    -- stub system.has_command to return false
    stub(system, "has_command", function(cmd)
      return false
    end)

    -- call the function and check error
    local ok, msg = rust.check_cargo_version()
    assert.is_false(ok)
    assert.is_truthy(msg)
  end)
end)
