--- macOS settings
---@class MacosSettings
---@field default_im string

--- Linux settings
---@class LinuxSettings
---@field default_im string
---@field get_im_command? string[]
---@field set_im_command? string[]

--- Plugin options
---@class PluginOptions
---@field mode? "restore"|"fixed" IM switching mode (default: "restore")
---@field macos? MacosSettings
---@field linux? LinuxSettings
