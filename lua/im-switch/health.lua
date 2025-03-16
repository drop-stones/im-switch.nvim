local opts = require("im-switch").opts
local utils = require("im-switch.utils")


--- Reports plugin status based on OS-specific options
local function check_os_options()
  local os = utils.detect_os()
  local platform_opts = opts[os]
  if os == "wsl" then
    platform_opts = opts.windows
  end

  if not platform_opts then
    vim.health.error(os .. " options are missing")
    return
  end

  if platform_opts.enabled then
    vim.health.ok("Plugin is enabled")
    if os == "mac" or os == "linux" then
      if type(platform_opts.default_im) == "string" then
        vim.health.ok("default_im is " .. platform_opts.default_im)
      else
        vim.health.error("default_im is not configured")
      end
    end
    if os == "linux" then
      for _, key in ipairs({ "obtain_im_command", "set_im_command" }) do
        if type(platform_opts[key]) == "table" then
          vim.health.ok(key .. " is " .. '"' .. utils.concat(platform_opts[key]) .. '"')
        elseif type(platform_opts[key]) == "string" then
          vim.health.ok(key .. " is " .. '"' .. platform_opts[key] .. '"')
        else
          vim.health.error(key .. " is not configured")
        end
      end
    end
  else
    vim.health.ok("Plugin is disabled")
  end
end

--- Check the availability of the im-switch binary
local function check_binary()
  if utils.should_build_with_cargo() and utils.executable("cargo") then

    if utils.get_built_executable_path():exists() then
      vim.health.ok("im-switch is built correctly")
    else
      vim.health.error("im-switch is not built correctly")
    end
  else
    local os, arch = utils.detect_os(), jit.arch
    if ((os == "windows" or os == "wsl") and arch == "x64") or (os == "mac" and arch == "arm64") then
      vim.health.ok("Prebuilt binary is used: " .. utils.get_prebuilt_executable_path())
    else
      vim.health.error("Prebuilt binary is not supported on this OS/architecture")
    end
  end
end

return {
  check = function()
    vim.health.start("im-switch.nvim")


    if not opts then
      vim.health.error("Plugin options are missing!")
      return
    end

    check_os_options()
    check_binary()
  end,
}
