--- Windows settings
---@class WindowsSettings
---@field enabled boolean

--- macOS settings
---@class MacosSettings
---@field enabled boolean
---@field default_im string

--- Linux settings
---@class LinuxSettings
---@field enabled boolean
---@field default_im string
---@field get_im_command string[]
---@field set_im_command string[]

--- Plugin options
---@class PluginOptions
---@field default_im_events string[] Events to set default input method
---@field save_im_state_events string[]  Events to save IM state
---@field restore_im_events string[] Events to restore IM state
---@field windows WindowsSettings
---@field macos MacosSettings
---@field linux LinuxSettings
