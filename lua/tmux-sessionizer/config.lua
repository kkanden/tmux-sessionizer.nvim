local M = {}

---@type tmux-sessionizer.Config
local default = {
    directories = { "~/projects", "~/.config" },
    max_depth = 2,
}

M.default = default

function M.setup_config(opts)
    local user_config = vim.tbl_deep_extend("force", M.default, opts)
    return user_config
end

return M
