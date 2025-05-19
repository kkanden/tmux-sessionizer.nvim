neovim wrapper of theprimeagen's tmux sessionizer.

> [!WARNING]  
> The plugin depends on the Snacks picker from the
> [Snacks](https://github.com/folke/snacks.nvim) plugin.

# Usage

The user is provided with a user command `:Tmux` that opens a Snacks picker with
the list of projects inside the directories specified by the user.

## Example configuration

Using `lazy.nvim`:

```lua
return {
    "kkanden/tmux-sessionizer.nvim",
    opts = {
        directories = { "~/projects", "~/.config" },
        max_depth = 2, -- how deep should the search be from the directory
    },
    config = function(_, opts)
        require("tmux-sessionizer").setup(opts)

        vim.keymap.set("n", "<leader>t", "<Cmd>Tmux<CR>", {})
    end,
}
```
