# im-switch.nvim

`im-switch.nvim` is a Neovim plugin that automatically switches the input method (IM) based on specific events.<br />
This is useful for users who frequently switch between different input methods (e.g., English and Japanese) while coding.

## ✨ Features

- 🔄 Switch input method according to Neovim events
- 📦 No need to install other tools to switch input method like [im-select](https://github.com/daipeihust/im-select)
- 🖥️  Works on Windows/macOS/Linux

## ⚡️ Requirements

| OS            | Requirements |
| ------------- | ------------ |
| **All OS**    | Neovim >= **0.10.0**<br />[plenary.nvim](https://github.com/nvim-lua/plenary.nvim) |
| **Windows/macOS** | `cargo` >= **1.93.0** _(optional)_ |
| **Linux**     | An input method framework (e.g., `fcitx5`, `ibus`) |

## 📦 Installation

Install the plugin with your preferred package manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ "nvim-lua/plenary.nvim", lazy = true }, -- plenary.nvim is required
{
  "drop-stones/im-switch.nvim",
  event = "VeryLazy",
  opts = {
    -- your configurations
  }
}
```

## 🚀 Quick Start

Add the following to your plugin configuration.<br />
This will switch to your default input method (e.g., English) when leaving insert mode.<br />
You can set `enabled = true` for any OS you use, and adjust `default_im` or commands as needed for each environment.

```lua
require("im-switch").setup({
  windows = {
    enabled = true, -- Set to true if you are on Windows/WSL2
  },
  macos = {
    enabled = true, -- Set to true if you are on macOS
    default_im = "com.apple.keylayout.ABC", -- or your preferred input method
  },
  linux = {
    enabled = true, -- Set to true if you are on Linux
    default_im = "keyboard-us", -- or your preferred input method
    get_im_command = { "fcitx5-remote", "-n" }, -- { "ibus", "engine" }
    set_im_command = { "fcitx5-remote", "-s" }, -- { "ibus", "engine" }
  },
})
```

## 🖥️  Executable for Input Method Switching

Neovim itself cannot switch the input method directly.<br />
Instead, this plugin invokes an external executable to handle the switching process.

### 🌐 Windows/macOS

On Windows/macOS, a Rust-based command-line utility, `im-switch`, is required.

If `cargo` is installed, `im_switch` will be built automatically during plugin installation.<br />
Otherwise, a pre-built binary will be downloaded using `curl` and used automatically.

> [!WARNING]
> Pre-built binaries are available only for:
>
> | OS      | Architecture      |
> | ------- | ----------------- |
> | Windows | x86_64            |
> | macOS   | aarch64, x86_64     |
>
> If you need a different version, make sure cargo is installed—then the plugin will automatically build the executable during installation.

> [!NOTE]
> The `im-switch` executable will also be rebuilt or updated automatically whenever you update this plugin.

### 🐧 Linux

On Linux, input method switching is handled through an input method framework (e.g., `fcitx5`, `ibus`).<br />

Make sure your system has an appropriate input method framework installed and configured.

## ⚙️  Configuration

You can customize **im-switch** behavior with the following options.<br />
Expand to see the list of all the default options below.

<details><summary>Default Options</summary>

```lua
{
  -- Events that set the default input method.
  default_im_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },

  -- Events that save the current input method.
  save_im_state_events = { "InsertLeavePre" },
  
  -- Events that restore the previously saved input method.
  restore_im_events = { "InsertEnter" },

  -- Windows settings
  windows = {
    -- Enable or disable the plugin on Windows/WSL2.
    enabled = false,
  };
  
  -- macOS settings
  macos = {
    -- Enable or disable the plugin on macOS.
    enabled = false,

    -- The input method set when `default_im_events` is triggered.
    default_im = "",
  },
  
  -- Linux settings
  linux = {
    -- Enable or disable the plugin on Linux.
    enabled = false,

    -- The input method set when `default_im_events` is triggered.
    default_im = "",

    -- The command used to get the current input method when `save_im_state_events` is triggered.
    get_im_command = {},

    -- The command used to set the input method when `default_im_events` or `restore_im_events` is triggered.
    set_im_command = {},
  },
}
```

</details>

### 🔧 General Configuration

#### `default_im_events`

Events that **set the default input method**.

```lua
default_im_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" }
```

#### `save_im_state_events`

Events that **save the current input method**.<br />
The saved input method is restored when `restore_im_events` is triggered.

```lua
save_im_state_events = { "InsertLeavePre" },
```

#### `restore_im_events`

Events that **restore the previously saved input method**.

```lua
restore_im_events = { "InsertEnter" },
```

> [!TIP]
> **Always Switch to Default IM on Mode Change**
>
> To always switch to the default IM instead of restoring the previous one:
>
> ```lua
> save_im_state_events = {},
> restore_im_events = {},
> ```

### 🪟 Windows Configuration

#### `windows.enabled`

Enable or disable the plugin on Windows/WSL2.

```lua
windows = {
  enabled = false,
},
```

### 🍎 macOS Configuration

#### `macos.enabled`

Enable or disable the plugin on macOS.

```lua
macos = {
  enabled = true,
},
```

#### `macos.default_im`

The input method set when `default_im_events` is triggered.

```lua
macos = {
  default_im = "com.apple.keylayout.ABC",
},
```

### 🐧 Linux Configuration

#### `linux.enabled`

Enable or disable the plugin on Linux.

```lua
linux = {
  enabled = true,
},
```

#### `linux.default_im`

The input method set when `default_im_events` is triggered.

```lua
linux = {
  default_im = "keyboard-us",
},
```

#### `linux.get_im_command`

The command used to **get the current input method** when `save_im_state_events` is triggered.

```lua
linux = {
  get_im_command = { "fcitx5-remote", "-n" },
},
```

#### `linux.set_im_command`

The command used to **set the input method** when `default_im_events` or `restore_im_events` is triggered.

```lua
linux = {
  set_im_command = { "fcitx5-remote", "-s" },
},
```

## 🩺 Troubleshooting

Run `:checkhealth im-switch` if you run into any issues.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
