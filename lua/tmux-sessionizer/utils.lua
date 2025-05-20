local M = {}

---@param cmd string
---@param opts? table
---@return string
---@return integer
---@return string
function M.cmd(cmd, opts)
    cmd = vim.split(cmd, " ")
    opts = opts or {}
    local obj = vim.system(cmd, opts):wait()
    return obj.stdout, obj.code, obj.stderr
end

function M.execute(cmd, opts)
    cmd = vim.split(cmd, " ")
    opts = opts or {}
    vim.system(cmd, opts)
end

---@param s string
---@return string
function M.strip(s) return string.match(s, "^%s*(.-)%s*$") end

function M.remove_empty(tbl)
    return vim.iter(tbl):filter(function(x) return x ~= "" end):totable()
end

function M.get_tmux_sessions()
    local stdout, code, _ = M.cmd("tmux list-sessions -F #{session_name}")
    if code ~= 0 then return end
    local sessions = vim.split(stdout, "\n")
    sessions = vim.iter(sessions)
        :map(function(x) return M.strip(x) end)
        :totable()
    return M.remove_empty(sessions)
end

function M.get_current_tmux_session()
    local stdout, _, _ = M.cmd("tmux display-message -p #S")
    return M.strip(stdout)
end

return M
