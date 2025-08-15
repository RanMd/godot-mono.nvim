# Godot Mono + Neovim 

<p align="center">
  <img src="https://godotengine.org/assets/press/icon_monochrome_dark.png" alt="Godot Logo" width="150"/>
  <img src="https://img.icons8.com/ios_filled/512/FFFFFF/c-sharp-logo.png" alt="Godot Logo" width="150"/>
</p>

Neovim plugin for working with Godot Mono (C#) projects, inspired by [vim-godot](https://github.com/habamax/vim-godot).

## Features

- Building the project to have changes.
- Run commands:
    - Run main scene: `:GodorRunMain`
    - Run last scene: `:GodotRunLast`
    - Select and run a scene: `:GodotRun`

All command are available only in projects with a project.godot file.

## Select and Run Scene

> [!IMPORTANT]
> The commands assume the Godot executable is on your PATH, i.e. you can run `godot-mono` from your terminal.
> If this is not the case, specify it in your settings.

- Use `:GodotRun` to open a picker and select a scene to run.
- Use `:GodotRunLast` to run the last executed scene.
- Use `:GodotRunMain` to run the main scene as defined in `project.godot`.

<https://github.com/user-attachments/assets/397b72ef-1c41-4316-806c-79d5b2c76837>

## Dependencies

- [Snacks](https://github.com/folke/snacks.nvim) (for the picker UI)
- [Neovim 0.10+](https://neovim.io/)
- [.NET SDK](https://dotnet.microsoft.com/en-us/download) (for building C# projects)

## Installation

Use your preferred plugin manager. For example, with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'RanMd/godot-mono.nvim',
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function(opts)
    require('godot-mono').setup(opts)
  end
}
```

## Configuration

You can configure the path to the Godot executable using the `opts` option in your Lazy spec:

```lua
{
  opts = {
    godot_executable = "/path/to/godot-mono", -- The path to the Godot executable to use for commands.
  }
}
```

This plugin does not set any default key mappings, so you can configure your own preferred shortcuts.

Here is an example configuration with custom keymaps:

```lua
{
  "RanMd/godot-mono.nvim",
  config = function(opts)
    local godot = require("godot-mono")
    godot.setup(opts)

    vim.keymap.set("n", "<leader>gf", "<cmd>GodotRun<CR>", { desc = "Select Godot scene" })
    vim.keymap.set("n", "<leader>gg", "<cmd>GodotRunLast<CR>", { desc = "Run last Godot scene" })
    vim.keymap.set("n", "<leader>gm", "<cmd>GodotRunMain<CR>", { desc = "Run main Godot scene" })
  end,
}
```

## Setup Neovim as an External Editor for Godot

Navigate to the root of your Godot project (where `project.godot` is located) and start Neovim with:

```bash
nvim --listen ./godothost
```

> [!TIP]
> You can use `vim.fn.serverstart("./godothost")` in your `init.lua` to automate this step.

> [!NOTE]
> On Windows, you might need to specify an IP:port combination, like `127.0.0.1:9696`.

In Godot, go to `Editor > Editor Settings` and navigate to `Dotnet/Editor/` (make sure to enable advanced settings to see all options):

- Select `Custom` in External editor
- Add `nvim` to `Exec Path` or browse for the executable
- Add the following to `Exec Flags`:

```bash
--server ./godothost --remote-send "<C-\\><C-N>:n {file}<CR>:call cursor({line},{col})<CR>"
```

Now, when you click on a script in Godot, it will open in a buffer in Neovim.

## Acknowledgements

- Inspired by [vim-godot](https://github.com/habamax/vim-godot) by habamax.
