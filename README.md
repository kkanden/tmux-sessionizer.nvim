neovim wrapper of theprimeagen's tmux sessionizer.

# Dependencies

- `tmux` (duh)
- `find` (found probably in all linux distros by default)

# Usage

The user is provided with a user command `:Tmux` that opens a picker with the
list of projects inside the directories specified by the user. If the
[Snacks](https://github.com/folke/snacks.nvim) plugin is available, then a
Snacks picker is opened, otherwise falls back to `vim.ui.select`.

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
