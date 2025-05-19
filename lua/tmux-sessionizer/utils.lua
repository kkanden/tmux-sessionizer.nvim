local M = {}

---@param cmd string[]
---@param opts? table
---@return string?
---@return integer
---@return string?
M.cmd = function(cmd, opts)
    opts = opts or {}
    local obj = vim.system(cmd, opts):wait()
    return obj.stdout, obj.code, obj.stderr
end

return M
