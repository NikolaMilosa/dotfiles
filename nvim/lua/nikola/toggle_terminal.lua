--- Spawns a toggleable terminal window t hat can be used to issue commands
--- and then remove if needed and takes up the whole screen

local M = {}

local shown = false

--- @class Terminal
--- @field buf number buffer number assigned to this terminal
--- @field win number window number assigned to this terminal
--- @field term_initialized boolean if the terminal is created or not
--- @field title number number of the title bar
--- @field title_text string text used as title bar

--- @type Terminal[]
local terminals = {}

--- @type Terminal
local active_terminal = {
    buf = 0,
    win = 0,
    term_initialized = false,
    title = 0,
    title_text = ""
}


local create_window = function()
    buf = vim.api.nvim_create_buf(false, true)
end

--- @param term Terminal which terminal to show
local show_window = function(term)
    local ui = vim.api.nvim_list_uis()[1]
    local width = math.floor(ui.width * 0.8)
    local height = math.floor(ui.height * 0.8)
    local col = math.floor((ui.width - width) / 2)
    local row = math.floor((ui.height - height) / 2)


    local title_buf = vim.api.nvim_create_buf(false, true)
    local title = string.format(" Terminal: %s ", term.title_text)
    vim.api.nvim_buf_set_lines(title_buf, 0, -1, false, { title })

    term.title = vim.api.nvim_open_win(title_buf, false, {
        relative = "editor",
        width = width,
        height = 1,
        col = col,
        row = row - 3, -- place it just above the terminal window
        style = "minimal",
        border = "rounded",
        noautocmd = true,
    })

    term.win = vim.api.nvim_open_win(term.buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
    })
    vim.api.nvim_set_current_buf(term.buf)

    if not term.term_initialized then
        vim.cmd("terminal")
        term.term_initialized = true
    end
end

--- @param term Terminal which terminal to hide
local hide_window = function(term)
    if term.win == 0 then
        return
    end
    if vim.api.nvim_win_is_valid(term.win) then
        vim.api.nvim_win_close(term.win, true)
    end

    if vim.api.nvim_win_is_valid(term.title) then
        vim.api.nvim_win_close(term.title, true)
    end
end

local toggle_term_window = function(term, title_text)
    local last = #terminals

    if term > last then
        for i = last + 1, term do
            curr_term = {
                buf = vim.api.nvim_create_buf(false, true),
                win = 0,
                title_text = title_text
            }
            table.insert(terminals, curr_term)
        end
    end

    local targeted_terminal = terminals[term]

    if targeted_terminal.buf == active_terminal.buf then
        -- Toggle active terminal
        if not shown then
            show_window(active_terminal)
        else
            hide_window(active_terminal)
        end
        shown = not shown
    else
        -- Turn off active terminal and open the new terminal
        hide_window(active_terminal)
        active_terminal = targeted_terminal
        show_window(active_terminal)
        shown = true
    end
end

function M.setup()
    vim.api.nvim_create_user_command("NikolaToggleTerm", toggle_term_window, {
        nargs = "*",
        desc = "Toggle the popup terminal window with console",
    })

    vim.keymap.set({ "n", "t" }, "<C-t>", function()
        toggle_term_window(1, "primary")
    end)
    vim.keymap.set({ "n", "t" }, "<C-z>", function()
        toggle_term_window(2, "secondary")
    end)
    vim.keymap.set({ "n", "t" }, "<C-u>", function()
        toggle_term_window(3, "tertiary")
    end)

    vim.keymap.set({ "n", "t" }, "<C-d>", "<nop>")
end

return M
