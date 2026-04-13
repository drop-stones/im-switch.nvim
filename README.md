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

## ⚙️ Configuration

### General options

| Key | Type | Default | Description |
| --- | ---- | ------- | ----------- |
| `mode` | `string` | `"restore"` | IM switching mode |

Available modes:

- **`"restore"`** (default) — Saves IM state per buffer on `InsertLeave` and restores it on `InsertEnter`.
- **`"fixed"`** — Always switches to the default IM. No save/restore.

### macOS

| Key | Type | Required | Description |
| --- | ---- | -------- | ----------- |
| `macos.default_im` | `string` | Yes | Default IM to switch to when leaving insert/cmdline mode |

```lua
require("im-switch").setup({
  macos = {
    default_im = "com.apple.keylayout.ABC",
  },
})
```

### Linux

| Key | Type | Required | Description |
| --- | ---- | -------- | ----------- |
| `linux.default_im` | `string` | Yes | Default IM to switch to when leaving insert/cmdline mode |
| `linux.get_im_command` | `string[]` | No | Custom command to get current IM (takes priority over CLI if set) |
| `linux.set_im_command` | `string[]` | No | Custom command to set IM (takes priority over CLI if set) |

```lua
require("im-switch").setup({
  linux = {
    default_im = "keyboard-us",
  },
})
```

> [!TIP]
> If your IM framework is not supported by the [`im-switch`](https://github.com/drop-stones/im-switch) CLI, you can use custom commands:
>
> ```lua
> linux = {
>   default_im = "default",
>   get_im_command = { "my-im-tool", "get" },
>   set_im_command = { "my-im-tool", "set" },
> }
> ```

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

## 🩺 Troubleshooting

Run `:checkhealth im-switch` if you run into any issues.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
