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

Configure the plugin for your OS to switch to the default IM on InsertLeave.

```lua
require("im-switch").setup({
  macos = {
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

| Key    | Type     | Default     | Description |
| ------ | -------- | ----------- | ----------- |
| `mode` | `string` | `"restore"` | `"restore"`: save/restore IM per buffer around insert mode. `"fixed"`: always use default IM. |

> [!TIP]
> **Always Switch to Default IM (fixed mode)**
>
> ```lua
> require("im-switch").setup({
>   mode = "fixed",
> })
> ```

### 🖥️ Platform options

#### 🪟 Windows/WSL2

The plugin is always enabled on Windows/WSL2. No configuration is needed.

#### 🍎 macOS (`macos`)

Add the `macos` table to enable the plugin on macOS.

| Key | Type | Default | Description |
| --- | ---- | ------- | ----------- |
| `macos.default_im` | `string` | — | IM to set on InsertLeave (e.g., `"com.apple.keylayout.ABC"`) |

#### 🐧 Linux (`linux`)

Add the `linux` table to enable the plugin on Linux.

| Key | Type | Default | Description |
| --- | ---- | ------- | ----------- |
| `linux.default_im` | `string` | — | IM to set on InsertLeave (framework-specific value) |
| `linux.get_im_command` | `string[]?` | — | Custom command to get current IM _(only needed for IM frameworks not supported by the CLI)_ |
| `linux.set_im_command` | `string[]?` | — | Custom command to set IM _(only needed for IM frameworks not supported by the CLI)_ |

On Linux, the plugin resolves IM switching in this order:

1. **Custom commands** — If `get_im_command`/`set_im_command` are configured, they are always used
2. **[`im-switch`](https://github.com/drop-stones/im-switch) CLI** — If no custom commands are configured, the installed CLI is used (supports [fcitx5](https://github.com/fcitx/fcitx5) and [ibus](https://github.com/ibus/ibus))

> [!TIP]
> **Example: Linux with [fcitx5](https://github.com/fcitx/fcitx5) or [ibus](https://github.com/ibus/ibus) (using im-switch CLI)**
>
> ```lua
> require("im-switch").setup({
>   linux = {
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
>     default_im = "default",
>     get_im_command = { "my-im-tool", "get" },
>     set_im_command = { "my-im-tool", "set" },
>   },
> })
> ```

## 🩺 Troubleshooting

Run `:checkhealth im-switch` if you run into any issues.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
