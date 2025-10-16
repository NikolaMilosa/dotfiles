local M = {}

local function sh(cmd)
    -- Run the shell command
    local output = vim.fn.system(cmd)

    -- Check the exit code
    local code = vim.v.shell_error
    if code ~= 0 then
        -- Print error (can also use vim.notify)
        vim.notify(string.format("Command failed (%d): %s\nOutput: %s", code, cmd, output), vim.log.levels.ERROR)
        return nil, output
    end

    return output
end

local function json(cmd)
    local ok, data = pcall(vim.json.decode, sh(cmd))
    if not ok then
        vim.notify("Failed to parse JSON: " .. tostring(data), vim.log.levels.ERROR)
        return nil
    end
    return data
end

-- Debug log function if needed
local LOG_FILE = nil

local log = function(msg)
    -- ensure message is a string
    msg = tostring(msg)

    -- include timestamp
    local line = string.format("[%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), msg)

    -- open file in append mode
    if not LOG_FILE then
        local file, err = io.open("/home/nikola/Downloads/log.log", "a")
        if not file then
            vim.notify("Could not open log file: " .. err, vim.log.levels.ERROR)
            return
        end
        LOG_FILE = file
    end

    LOG_FILE:write(line)
    LOG_FILE:flush()
end

local function get_window(dir, active, clients)
    local ax, ay = active.at[1], active.at[2]

    local win = nil

    local smallest_next = nil

    for _, c in ipairs(clients) do
        if c.address == active.address then
            goto continue
        end
        if c.hidden then
            goto continue
        end
        local cx, cy = c.at[1], c.at[2]

        if dir == "l" and cx <= ax then
            if smallest_next == nil or cx > smallest_next then
                smallest_next = cx
                win = c
            end
        end
        if dir == "r" and cx >= ax then
            if smallest_next == nil or cx < smallest_next then
                smallest_next = cx
                win = c
            end
        end

        if dir == "d" and cy <= ay then
            if smallest_next == nil or cy > smallest_next then
                smallest_next = cy
                win = c
            end
        end
        if dir == "u" and cy >= ay then
            if smallest_next == nil or cy < smallest_next then
                smallest_next = cy
                win = c
            end
        end
        ::continue::
    end

    return win
end

local filter_out_non_active_workspaces = function(clients, monitors)
    -- Step 1: Collect all active workspace IDs
    local active_workspaces = {}
    for _, mon in ipairs(monitors or {}) do
        if mon.activeWorkspace and mon.activeWorkspace.id then
            active_workspaces[mon.activeWorkspace.id] = true
        end
    end

    -- Step 2: Filter clients that belong to an active workspace
    local visible_clients = {}
    for _, c in ipairs(clients or {}) do
        if c.workspace and active_workspaces[c.workspace.id] then
            table.insert(visible_clients, c)
        end
    end

    return visible_clients
end

local open_in_direction = function(dir)
    local work_dir = vim.fn.getcwd()
    local bufnr = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(bufnr)

    local monitors = json("hyprctl -j monitors")
    if not monitors then return nil end

    local active = json("hyprctl -j activewindow")
    if not active then return nil end

    local clients = json("hyprctl -j clients")
    if not clients then return nil end

    clients = filter_out_non_active_workspaces(clients, monitors)

    local win = get_window(dir, active, clients)
    if not win then return nil end

    if win.class ~= "kitty" then
        -- spawn a new terminal to the "dir" of this one
        -- update win to show to that client
        sh("hyprctl dispatch movefocus " .. dir)
        sh("hyprctl dispatch exec kitty")
        -- refresh the window info
        clients = json("hyprctl -j clients")
        clients = filter_out_non_active_workspaces(clients, monitors)
        win = get_window(dir, active, clients)
        if not win then return nil end
    end

    if win.title:match("^~") then
        log("Opening whole nvim in " .. win.title .. " on pid " .. win.pid)
        sh(string.format("kitty @ launch nvim --cmd '%s' '%s' --match pid:%s ",
            work_dir, buf_name, win.pid))
    else
        log("Openning a file in " .. win.title .. " on pid " .. win.pid)
        sh(string.format(
            "kitty @ send-text --match pid:%s ':edit %s\\r'",
            win.pid,
            buf_name
        ))
    end
end

function M.setup()
    vim.keymap.set("n", "s", "<Nop>")

    -- Mapping neovim <-> hyprland
    local directions = {
        h = "l",
        j = "d",
        k = "u",
        l = "r"
    }

    for key, dir in pairs(directions) do
        vim.keymap.set("n", "<leader>s" .. key, function()
            open_in_direction(dir)
        end)
    end
end

M.setup()
