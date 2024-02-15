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

function M.get_cargo_toml_path()
	return get_plugin_root_path():joinpath("Cargo.toml"):absolute()
end

function M.get_executable_path()
	local executable_path =
		get_plugin_root_path():joinpath("target/release/im-switch" .. get_executable_extension(false))
	local prebuilt_executable_path = get_plugin_root_path():joinpath("bin/im-switch" .. get_executable_extension(true))
	if executable_path:exists() then
		return executable_path:absolute()
	else
		return prebuilt_executable_path:absolute()
	end
end

local function get_current_im(opts)
	local current_im = ""
	local os = M.get_os()
	if (os == "wsl") or (os == "windows") then
		current_im = vim.fn.system({ M.get_executable_path(), "--get" })
	elseif os == "mac" then
		current_im = vim.fn.system({ M.get_executable_path(), "--get" })
	elseif os == "linux" then
		current_im = vim.fn.system(opts.linux.obtain_im_command)
	end
	return current_im:gsub("%s+", "") -- trim all spaces
end

function M.save_im(opts)
	local current_im = get_current_im(opts)
	vim.api.nvim_buf_set_var(0, "saved_im", current_im)
end

function M.ime_off(opts)
	local os = M.get_os()
	if (os == "wsl") or (os == "windows") then
		vim.fn.system({ M.get_executable_path(), "--inactivate" })
	elseif os == "mac" then
		vim.fn.system({ M.get_executable_path(), "--set", opts.mac.default_im })
	elseif os == "linux" then
		vim.fn.system(opts.linux.set_im_command .. " " .. opts.linux.default_im)
	end
end

function M.restore_previous_im(opts)
	if vim.b["saved_im"] == nil then
		M.save_im(opts)
		return
	end

	local previous_im = vim.api.nvim_buf_get_var(0, "saved_im")

	local os = M.get_os()
	if (os == "wsl") or (os == "windows") then
		if previous_im == "on" then
			vim.fn.system({ M.get_executable_path(), "--activate" })
		elseif previous_im == "off" then
			vim.fn.system({ M.get_executable_path(), "--inactivate" })
		end
	elseif os == "mac" then
		vim.fn.system({ M.get_executable_path(), "--set", previous_im })
	elseif os == "linux" then
		vim.fn.system(opts.linux.set_im_command .. " " .. previous_im)
	end
end

return M
