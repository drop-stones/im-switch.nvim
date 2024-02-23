# im-switch.nvim

`im-switch.nvim` is a Neovim plugin to switch input method automatically.

## ✨ Features

- 🔄 Switch input method according to Neovim events
- 📦 No need to install other tools to switch input method like [im-select](https://github.com/daipeihust/im-select)
- 🖥️  Works on Windows/Mac/Linux

## ⚡️ Requirements

- Neovim >= **0.9.0**
- cargo >= **1.75.0** **_(optional)_**

## 📦 Installation

Install the plugin with your preferred package manager.

> [!NOTE]
> Windows/Mac
>
> If `cargo` is installed, `im_switch` is built at installation.
> If not, the pre-built binary is used.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "drop-stones/im-switch.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy",
  opts = {
    -- your configurations
  }
}
```

## ⚙️  Configuration

```lua
{
  -- Set the default input method when the following events are triggered.
  -- By default, `{ "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" }` are registered.
  -- If you want to disable this behavior, set empty as `set_default_im_events = {}`.
  set_default_im_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },

  -- Save the current input method when the following events are triggered.
  -- The saved input method is restored when events in `set_previous_im_events` are triggered.
  -- By default, `InsertLeavePre` is registered.
  save_im_events = { "InsertLeavePre" },
  
  -- Set the previous input method when the following events are triggered.
  -- The previous input method is saved when events in `save_im_events` are triggered.
  -- By default, `InsertEnter` is registered.
  -- If you want to disable this behavior, set `save_im_events` and `set_previous_im_events` to empty.
  set_previous_im_events = { "InsertEnter" },

  -- Options for windows
  windows = {
    -- Enable this plugin on Windows.
    -- If enabled, input method is inactivated when events in `set_default_im_events` are triggered.
    -- And the previous state of input method is restored when events in `set_previous_im_events` are triggered.
    -- By default, the value is false.
    enabled = true,
  },
  
  -- Options for mac
  mac = {
    -- Enable this plugin on Mac.
    -- The following settings is required to enable this plugin on Mac.
    -- By default, the value is false.
    enabled = true,
    
    -- The input method is set when events in `set_default_im_events` are triggered
    default_im = "com.apple.inputmethod.XXX",
  },
  
  -- Options for linux
  linux = {
    -- Enable this plugin on Linux.
    -- The following settings is required to enable this plugin on Linux.
    -- By default, the value is false.
    enabled = true,
    
    -- The input method is set when events in `set_default_im_events` are triggered
    default_im = "keyboard-us",

    -- The command to get the current input method.
    -- This is executed when events in `save_im_events` are triggered.
    -- The command need to be a string or list.
    obtain_im_command = "fcitx5-remote -n",

    -- The command to set a new input method.
    -- This is executed when events in `set_default_im_events` or `set_previous_im_events` are triggered.
    -- The command need to be a string or list.
    set_im_command = { "fcitx5-remote", "-s" },
  },
}
```
