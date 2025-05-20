local M = {}

local has_snacks, Snacks = pcall(require, "snacks")

if vim.fn.executable("find") == 0 then
    vim.notify(
        "tmux-sessionizer: `find` is not executable.",
        vim.log.levels.ERROR,
        { title = "tmux-sessionizer.nvim" }
    )
    return
end

if vim.fn.executable("tmux") == 0 then
    vim.notify(
        "tmux-sessionizer: `tmux` is not executable.",
        vim.log.levels.ERROR,
        { title = "tmux-sessionizer.nvim" }
    )
    return
end

local config = require("tmux-sessionizer.config")
local utils = require("tmux-sessionizer.utils")

local tmux_current_session = os.getenv("TMUX")
    and utils.get_current_tmux_session()
local tmux_sessions = utils.get_tmux_sessions() or {}

local function get_projects(dirs, max_depth)
    local command =
        { "find", ("-mindepth 0 -maxdepth %s -type d"):format(max_depth) }
    for i, v in ipairs(dirs) do
        local path = vim.fs.normalize(v)
        if not vim.fn.isabsolutepath(path) == 0 then
            path = vim.fs.joinpath(os.getenv("HOME"), path)
        end
        table.insert(command, i + 1, path)
    end
    command = table.concat(command, " ")
    local stdout, code, stderr = utils.cmd(command, { text = true })
    if code ~= 0 then error(stderr, vim.log.levels.ERROR) end

    if not stdout or #stdout == 0 then
        vim.notify(
            "No folders found within specified directories",
            vim.log.levels.WARN
        )
        return
    end

    local projects = vim.split(stdout, "\n")
    return utils.remove_empty(projects)
end

local function create_snacks_items(entries)
    local items = { max = 0 }
    for i, item in ipairs(entries) do
        local tmux_name =
            utils.strip(string.gsub(vim.fs.basename(item), "%.", "_"))
        local icon = "󰉋 "
        local hl = ""
        if tmux_name == tmux_current_session then
            icon = "󰝰 "
            hl = "Green"
        elseif vim.tbl_contains(tmux_sessions, tmux_name) then
            hl = "Blue"
        end

        if #item > items.max then items.max = #item end

        table.insert(items, {
            idx = i,
            score = i,
            name = item,
            text = item,
            tmux_name = tmux_name,
            icon = icon,
            hl = hl,
        })
    end

    return items
end

local function tmux_open(project)
    if not project then return end
    local selected_name = vim.fs.basename(project)
    selected_name = string.gsub(selected_name, "%.", "_")

    local tmux_env = os.getenv("TMUX")
    local stdout, _, _ = utils.cmd("pgrep tmux")
    local tmux_running = stdout ~= ""

    if not tmux_env and not tmux_running then
        os.execute(
            ("tmux new-session -s %s -c %s"):format(selected_name, project)
        )
        return
    end

    local _, code, _ = utils.cmd("tmux has-session -t=" .. selected_name)

    if code ~= 0 then
        os.execute(
            ("tmux new-session -ds %s -c %s"):format(selected_name, project)
        )
    end

    if not tmux_env then
        os.execute(("tmux attach -t %s"):format(selected_name))
    else
        os.execute(("tmux switch-client -t %s"):format(selected_name))
    end
end

function M.sessionizer()
    local dirs = config.opts.directories
    local max_depth = config.opts.max_depth
    local projects = get_projects(dirs, max_depth)
    if not projects then return end

    if has_snacks then
        local items = create_snacks_items(projects)
        local padding = items.max + 5
        Snacks.picker({
            items = items,
            layout = { preset = "select" },
            format = function(item)
                local parent, base = string.match(item.text, "(.*)/(.*)")
                local ret = {}
                ret[#ret + 1] = { item.icon, item.hl }
                ret[#ret + 1] = { parent .. "/", "Comment" }
                ret[#ret + 1] = { base }
                ret[#ret + 1] =
                    { string.rep(" ", padding - #item.text), virtual = true }
                ret[#ret + 1] = { item.tmux_name, "Comment" }
                return ret
            end,
            confirm = function(picker, item)
                picker:close()
                tmux_open(item.name)
            end,
        })
    else
        vim.ui.select(
            projects,
            { prompt = "Select project folder" },
            function(item) tmux_open(item) end
        )
    end
end

function M.setup(opts)
    config.opts = config.setup_config(opts)

    vim.api.nvim_create_user_command("Tmux", function() M.sessionizer() end, {})
end

return M
