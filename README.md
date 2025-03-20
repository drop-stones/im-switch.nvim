# im-switch.nvim

`im-switch.nvim` is a Neovim plugin to switch input method automatically.

## ✨ Features

- 🔄 Switch input method according to Neovim events
- 📦 No need to install other tools to switch input method like [im-select](https://github.com/daipeihust/im-select)
- 🖥️  Works on Windows/Mac/Linux

## ⚡️ Requirements

- Neovim >= **0.10.0**
- cargo >= **1.75.0** **_(optional)_**

## 📦 Installation

Install the plugin with your preferred package manager.

> [!NOTE]
> Windows/macOS
>
> If `cargo` is installed, `im_switch` is built during installation.  
> Otherwise, a pre-built binary is used.

> [!WARNING]
>
> The following binaries are pre-built.  
> If you need a different binaries, install `cargo` and build the plugin yourself.
>
> | OS      | Architecture |
> | ------- | ------------ |
> | Windows | x86_64       |
> | macOS   | arm64        |

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

  -- Windows settings
  windows = {
    -- Enable this plugin on Windows.
    -- If enabled, input method is inactivated when events in `set_default_im_events` are triggered.
    -- And the previous state of input method is restored when events in `set_previous_im_events` are triggered.
    -- By default, this plugin is disabled on Windows.
    enabled = true,
  };
  
  -- Mac settings
  mac = {
    -- Enable this plugin on Mac.
    -- The following settings is required to enable this plugin on Mac.
    -- By default, this plugin is disabled on Mac.
    enabled = true,

    -- The input method is set when events in `set_default_im_events` are triggered
    default_im = "com.apple.inputmethod.XXX",
  },
  
  -- Linux settings
  linux = {
    -- Enable this plugin on Linux.
    -- The following settings is required to enable this plugin on Linux.
    -- By default, this plugin is disabled on Linux.
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

### Examples

#### Example 1

- Restore the previous input method when transitioning to input mode
  - Default behavior
- Enable this plugin on Windows, Mac and Linux
- Use `fcitx5-remote` to switch input methods on Linux

```lua
{
  -- No event settings are required if default settings are used

  windows = {
    enabled = true,
  },

  mac = {
    enabled = true,
    default_im = "com.apple.keylayout.ABC", -- If you use Japanese, use "com.apple.inputmethod.Kotoeri.RomajiTyping.Roman" instead
  },

  linux = {
    enabled = true,
    default_im = "keyboard-us",
    obtain_im_command = { "fcitx5-remote", "-n" },
    set_im_command = { "fcitx5-remote", "-s" },
  },
}
```

#### Example 2

- Always set the default input method when transitioning to input mode
- Enable this plugin on Windows, Mac and Linux
- Use `ibus` to switch input methods on Linux

```lua
{
  -- Disable default behaviors to restore the previous input method
  set_previous_im_events = {},
  save_im_events = {},
  
  windows = {
    enabled = true,
  },

  mac = {
    enabled = true,
    default_im = "com.apple.keylayout.ABC",
  },

  linux = {
    enabled = true,
    default_im = "xkb:us::eng",
    obtain_im_command = { "ibus", "engine" },
    set_im_command = { "ibus", "engine" },
  },
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
