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
>   If `cargo` is installed, `im_switch` is built at installation.
>   If not, the pre-built binary is used.

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
  mac = {
    -- IM set in `normal` mode on mac
    default_im = "com.apple.inputmethod.XXX",
  },
  
  linux = {
    -- Command to be executed when transitioning to `normal` mode on linux
    switch_to_default_im_command = "fcitx5-remote -c",
  },
  
  -- IM is inactivated when transitioning to `normal` mode on windows
}
```
