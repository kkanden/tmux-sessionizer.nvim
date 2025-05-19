local M = {}

local ok, Snacks = pcall(require, "snacks")
if not ok then
    vim.notify("folke's Snacks picker is required.", vim.log.levels.ERROR)
    return
end

local config = require("tmux-sessionizer.config")
local utils = require("tmux-sessionizer.utils")

local function get_projects(dirs, max_depth)
    local args = {
        "find",
        "-mindepth",
        "0",
        "-maxdepth",
        tostring(max_depth),
        "-type",
        "d",
    }
    for i, v in ipairs(dirs) do
        local path = vim.fs.normalize(v)
        if not vim.fn.isabsolutepath(path) == 0 then
            path = vim.fs.joinpath(os.getenv("HOME"), path)
        end
        table.insert(args, i + 1, path)
    end
    local stdout, code, stderr = utils.cmd(args, { text = true })
    if code ~= 0 then error(stderr, vim.log.levels.ERROR) end

    if not stdout or #stdout == 0 then
        vim.notify(
            "No folders found within specified directories",
            vim.log.levels.WARN
        )
        return
    end

    local projects = vim.split(stdout, "\n")
    return projects
end

local function create_items(entries)
    local items = {}
    for i, v in ipairs(entries) do
        table.insert(items, {
            idx = i,
            score = i,
            name = v,
            text = v,
        })
    end
    return items
end

function M.sessionizer()
    local dirs = config.opts.directories
    local max_depth = config.opts.max_depth
    local projects = get_projects(dirs, max_depth)
    local items = create_items(projects)

    return Snacks.picker({
        items = items,
        layout = { preset = "select" },
        format = function(item)
            local ret = {}
            ret[#ret + 1] =
                { ("%-" .. "s"):format(item.name), "SnacksPickerLabel" }
            return ret
        end,
        confirm = function(picker, item)
            picker:close()
            vim.notify(item.name, 2)
        end,
    })
end

function M.setup(opts)
    config.opts = config.setup_config(opts)

    vim.api.nvim_create_user_command("Tmux", function() M.sessionizer() end, {})
end

return M
