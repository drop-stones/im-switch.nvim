# im-switch.nvim

`im-switch.nvim` automatically switches your input method (IM) in Neovim based on events (e.g. `InsertLeave`, `InsertEnter`).
It helps when you frequently switch between English and non-English IMs while coding.

## ✨ Features

- 🔄 Switch input method according to Neovim events
- 📦 No need to install other tools to switch input method like [im-select](https://github.com/daipeihust/im-select)
- 🖥️ Works on Windows/WSL2/macOS/Linux

## ⚡️ Requirements

| OS            | Requirements |
| ------------- | ------------ |
| **All OS**    | Neovim >= **0.10.0**<br />[plenary.nvim](https://github.com/nvim-lua/plenary.nvim) |
| **Windows/macOS** | `cargo` >= **1.93.0** _(optional; used to build `im-switch`)_ |
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

Enable the plugin for your OS to switch to the default IM on InsertLeave.

```lua
require("im-switch").setup({
  macos = {
    enabled = true,
    default_im = "com.apple.keylayout.ABC",
  },
})
```

## 🔄 How it switches IM

Neovim cannot switch IM directly, so this plugin uses an external method depending on your OS:

- Windows/macOS: uses a helper executable named `im-switch` (built with Cargo or downloaded as a prebuilt binary)
- Linux: runs your configured IM framework commands (e.g. `fcitx5-remote`, `ibus`)

<details><summary>Windows/macOS helper details</summary>

- If `cargo` is available, `im-switch` is built automatically during installation/update.
- Otherwise, a prebuilt binary is downloaded.

> **WARNING:**
> Prebuilt binaries are available only for:
>
> | OS           | Architecture      |
> | -------      | ----------------- |
> | Windows/WSL2 | x86_64            |
> | macOS        | aarch64, x86_64   |
>
> If you need a different version, make sure cargo is installed—then the plugin will automatically build the executable during installation.

> **NOTE:**
> **WSL2** users must use the Windows prebuilt binary.
> Building with `cargo` inside WSL2 is not supported.

</details>

## ⚙️  Configuration

### 🔧 General options

| Key                  | Type     | Default | Description |
| -------------------- | -------- | ------- | ----------- |
| `default_im_events`    | `string[]` | `{ "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" }` | Events that set the **default IM** |
| `save_im_state_events` | `string[]` | `{ "InsertLeavePre" }` | Events that **save** the current IM |
| `restore_im_events`    | `string[]` | `{ "InsertEnter" }` | Events that **restore** the saved IM |

> [!TIP]
> **Always Switch to Default IM on Mode Change (disable save/restore)**
>
> ```lua
> require("im-switch").setup({
>  save_im_state_events = {},
>  restore_im_events = {},
> })
> ```

### 🖥️ OS options

#### 🪟 Windows/WSL2 (`windows`)

| Key | Type | Default | Description |
| --- | ---- | ------- | ----------- |
| `windows.enabled` | `boolean` | `false` | Enable on Windows/WSL2 |

#### 🍎 macOS (`macos`)

| Key | Type | Default | Description |
| --- | ---- | ------- | ----------- |
| `macos.enabled` | `boolean` | `false` | Enable on macOS |
| `macos.default_im` | `string` | `""` | IM to set when `default_im_events` triggers (e.g., `"com.apple.keylayout.ABC"`) |

#### 🐧 Linux (`linux`)

| Key | Type | Default | Description |
| --- | ---- | ------- | ----------- |
| `linux.enabled` | `boolean` | `false` | Enable on Linux |
| `linux.default_im` | `string` | `""` | IM to set when `default_im_events` triggers (framework-specific value) |
| `linux.get_im_command` | `string[]` | `{}` | Command to get current IM when `save_im_state_events` triggers |
| `linux.set_im_command` | `string[]` | `{}` | Command to set IM when `default_im_events` or `restore_im_events` triggers |

> [!TIP]
> **Example (fcitx5)**
>
> ```lua
> require("im-switch").setup({
>   linux = {
>     enabled = true,
>     default_im = "keyboard-us",
>     get_im_command = { "fcitx5-remote", "-n" },
>     set_im_command = { "fcitx5-remote", "-s" },
>   },
> })
> ```

<details><summary>Default options</summary>

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

## 🩺 Troubleshooting

Run `:checkhealth im-switch` if you run into any issues.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
