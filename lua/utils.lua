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
	local root_path = debug.getinfo(2, "S").source:sub(2)
	if M.get_os() == "windows" then
		-- need to replace path delimiters due to bugs of plenary
		root_path = string.gsub(root_path, "/", "\\")
	end
	return Path:new(root_path):parent():parent()
end

function M.is_supported()
	local os = M.get_os()
	return (os == "windows") or (os == "wsl")
end

function M.get_cargo_toml_path()
	return get_plugin_root_path():joinpath("Cargo.toml"):absolute()
end

function M.get_executable_path()
	local executable_path = get_plugin_root_path():joinpath("target/release/ime-switch-win.exe")
	local prebuilt_executable_path = get_plugin_root_path():joinpath("bin/ime-switch-win.exe")
	if executable_path:exists() then
		return executable_path:absolute()
	else
		return prebuilt_executable_path:absolute()
	end
end

return M