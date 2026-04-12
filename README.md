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
| **All OS**    | Neovim >= **0.10.0** |
| **Linux**     | An input method framework (e.g., `fcitx5`, `ibus`) |

> [!NOTE]
> The plugin automatically downloads the [`im-switch`](https://github.com/drop-stones/im-switch) CLI binary during installation.
> No manual setup is required for Windows/WSL2/macOS.
> On Linux, the CLI supports [fcitx5](https://github.com/fcitx/fcitx5) and [ibus](https://github.com/ibus/ibus) natively, but you can also use custom commands for other frameworks.

## 📦 Installation

Install the plugin with your preferred package manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
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

Neovim cannot switch IM directly, so this plugin uses the [`im-switch`](https://github.com/drop-stones/im-switch) CLI:

- **Windows/WSL2**: Toggles IME on/off via `im-switch ime enable/disable`
- **macOS**: Switches input source via `im-switch set <input_source_id>`
- **Linux**: Uses `im-switch` CLI (fcitx5/ibus) or user-configured custom commands

The CLI binary is automatically downloaded from [GitHub Releases](https://github.com/drop-stones/im-switch/releases) during plugin installation.

| OS           | Architecture      |
| ------------ | ----------------- |
| Windows/WSL2 | x86_64, aarch64   |
| macOS        | x86_64, aarch64   |
| Linux        | x86_64, aarch64   |

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
| `linux.get_im_command` | `string[]?` | `{}` | Custom command to get current IM _(only needed for IM frameworks not supported by the CLI)_ |
| `linux.set_im_command` | `string[]?` | `{}` | Custom command to set IM _(only needed for IM frameworks not supported by the CLI)_ |

On Linux, the plugin resolves IM switching in this order:

1. **Custom commands** — If `get_im_command`/`set_im_command` are configured, they are always used
2. **[`im-switch`](https://github.com/drop-stones/im-switch) CLI** — If no custom commands are configured, the installed CLI is used (supports [fcitx5](https://github.com/fcitx/fcitx5) and [ibus](https://github.com/ibus/ibus))

> [!TIP]
> **Example: Linux with [fcitx5](https://github.com/fcitx/fcitx5) or [ibus](https://github.com/ibus/ibus) (using im-switch CLI)**
>
> ```lua
> require("im-switch").setup({
>   linux = {
>     enabled = true,
>     default_im = "keyboard-us",
>   },
> })
> ```

> [!TIP]
> **Example: Linux with custom commands (for other IM frameworks)**
>
> If you use an IM framework not supported by the `im-switch` CLI, you can specify custom commands:
>
> ```lua
> require("im-switch").setup({
>   linux = {
>     enabled = true,
>     default_im = "default",
>     get_im_command = { "my-im-tool", "get" },
>     set_im_command = { "my-im-tool", "set" },
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
  },

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

    -- Custom command to get the current input method (optional).
    -- If set, takes priority over the im-switch CLI.
    get_im_command = {},

    -- Custom command to set the input method (optional).
    -- If set, takes priority over the im-switch CLI.
    set_im_command = {},
  },
}
```

</details>

## 🩺 Troubleshooting

Run `:checkhealth im-switch` if you run into any issues.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
