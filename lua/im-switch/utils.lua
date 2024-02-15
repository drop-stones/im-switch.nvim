local Path = require("plenary.path")

local M = {}

function M.get_os()
  if vim.fn.has("wsl") == 1 then
    return "wsl"
  elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    return "windows"
  elseif vim.fn.has("mac") == 1 then
    return "mac"
  elseif vim.fn.has("linux") == 1 then
    return "linux"
  else
    print("Unsupported OS")
    os.exit(1)
  end
end

function M.need_cargo_build()
  local os = M.get_os()
  return (os == "mac") or (os == "windows")
end

-- get root path
local function get_plugin_root_path()
  local utils_path = debug.getinfo(2, "S").source:sub(2)
  if M.get_os() == "windows" then
    -- need to replace path delimiters due to bugs of plenary
    utils_path = string.gsub(utils_path, "/", "\\")
  end
  return Path:new(utils_path):parent():parent():parent()
end

function M.get_cargo_toml_path()
  return get_plugin_root_path():joinpath("Cargo.toml"):absolute()
end

-- get extension
local function get_executable_extension(is_prebuilt)
  local os = M.get_os()
  if (os == "wsl") or (os == "windows") then
    return ".exe"
  elseif os == "mac" then
    if is_prebuilt == true then
      return ".bin"
    end
  end
  return ""
end

function M.get_built_executable_path()
  return get_plugin_root_path():joinpath("target/release/im-switch" .. get_executable_extension(false))
end

function M.get_executable_path()
  local executable_path = M.get_built_executable_path()
  local prebuilt_executable_path = get_plugin_root_path():joinpath("bin/im-switch" .. get_executable_extension(true))
  if executable_path:exists() then
    return executable_path:absolute()
  else
    return prebuilt_executable_path:absolute()
  end
end

function M.concat(list)
  if type(list) == "table" then
    local len = #list
    if len == 0 then
      return ""
    end

    local str = list[1]
    for i = 2, len do
      str = str .. " " .. list[i]
    end
    return str
  else
    return list
  end
end

return M
