--- Only create these if you are in a leet code
--- directory at home.

local M = {}

local open_buffer_and_set_as_active = function(name)
    vim.cmd("edit " .. name)
    vim.cmd("write!")
end

local add_module_to_lib = function(name)
    local lib = vim.fn.getcwd() .. "/src/lib.rs"

    local f = io.open(lib, "r")
    local content = ""
    if f then
        content = f:read("*all")
        f:close()
    end

    -- Write the new line + old content
    f = io.open(lib, "w")
    if f then
        f:write("mod " .. name .. ";\n" .. content)
        f:close()
    else
        error("Could not open file for writing: " .. lib)
    end

    -- format lib
    vim.system({ "rustfmt", lib })
end

local save_file = function(name, lines)
    local new_file = vim.fn.getcwd() .. "/src/" .. name .. ".rs"

    if vim.fn.filereadable(new_file) == 1 then
        vim.notify("File `" .. new_file .. "` already exists so pick a different name", vim.log.levels.ERROR)
        return
    end

    local fd = io.open(new_file, "w")
    if fd then
        fd:write(table.concat(lines, "\n"))
        fd:close()
    else
        vim.notify("Failed to write to `" .. new_file .. "`", vim.log.levels.ERROR)
        return
    end

    -- format the new file
    vim.system({ "rustfmt", new_file })
    add_module_to_lib(name)
    open_buffer_and_set_as_active(new_file)
end

local parse_lines = function(lines)
    local contents = {}
    local problem_name = nil

    for _, line in ipairs(lines) do
        local comment = line:match("^%s*//%s*(.*)")
        if comment then
            local name = comment:match("Problem name:%s*`([^`]+)`")
            if name then
                problem_name = name
            end
        else
            table.insert(contents, line)
        end
    end

    -- This is just randomly picked because it will usually be something like the following
    -- impl Solution {
    --      pub fn find_even_numbers(digits: Vec<i32>) -> Vec<i32> {
    --
    --      }
    -- }
    if #contents <= 2 then
        vim.notify("No contents detected. Did you paste the snippet from the leet code?", vim.log.levels.ERROR)
        return
    end

    table.insert(contents, 1, "use crate::Solution;")

    -- Generate two test cases
    for _, test_case in ipairs({ 1, 2 }) do
        table.insert(contents, "")
        table.insert(contents, "#[test]")
        table.insert(contents, "fn " .. problem_name .. "_" .. test_case .. "()" .. "{}")
    end

    save_file(problem_name, contents)
end

local yank_buffer = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    local lines_to_yank = {}

    for _, line in ipairs(lines) do
        if line:match("^use%s+crate::Solution;$") then
            goto continue
        end

        if line == "#[test]" then
            break
        end

        table.insert(lines_to_yank, line)

        ::continue::
    end

    vim.fn.setreg("*", table.concat(lines_to_yank, "\n"))
end

local run_test_for_current_problem = function()
    local filename = vim.fn.expand("%:t:r")

    local ui = vim.api.nvim_list_uis()[1]
    local width = math.floor(ui.width * 0.8)
    local height = math.floor(ui.height * 0.8)
    local col = math.floor((ui.width - width) / 2)
    local row = math.floor((ui.height - height) / 2)

    local buf = vim.api.nvim_create_buf(false, true)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
    })

    vim.api.nvim_set_current_buf(buf)

    vim.fn.jobstart({ 'cargo', 'test', '--', filename }, {
        term = true
    })

    vim.keymap.set("n", "q", function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end, { buffer = buf, nowait = true, silent = true })
end

local create_new_problem = function()
    --   Create a scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = "rust"

    -- Paste the provided text (from args) or a default snippet
    local text = { "// Paste the initialization code from leetcode below this comment.",
        "// The comments will be ignored and whatever is commented will be skipped in the actual snippet. ",
        "// ",
        "// Enter the problem name between ``.",
        "// **NOTE**: the problem name should be a single word without `*.rs` at the end.",
        "// Problem name: `some_problem`", "//", "" }
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, text)

    -- Find the line and column to place the cursor
    local target_line = 6
    local col = text[target_line]:find("some_problem") - 1
    -- Set cursor position in the current window
    vim.api.nvim_win_set_cursor(0, { target_line, col })

    -- Map <CR> in normal mode for this buffer only
    vim.keymap.set("n", "<CR>", function()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        parse_lines(lines)
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end, { buffer = buf, nowait = true })
end

function M.setup()
    local working_dir = vim.fn.getcwd()
    local pattern = "work/Personal/some-more-leet"
    -- local pattern = ".config/nvim"

    -- Check if we are in the correct directory
    if working_dir:sub(- #pattern) ~= pattern then
        return
    end
    vim.notify("Detected leet dir, loading some utilities...", vim.log.levels.INFO)

    -- Add a command to open a buffer, paste the text and close the buffer
    vim.api.nvim_create_user_command("LeetPaste", create_new_problem, {
        nargs = "*",
        desc = "Open a scratch buffer, paste text, and close it",
    })
    vim.keymap.set("n", "<leader>o", create_new_problem)

    -- Add a command to yank the solution to system clipboard
    vim.api.nvim_create_user_command("LeetYank", yank_buffer, {
        desc = "Yank only the solution code from the buffer"
    })

    vim.keymap.set({ "x", "o", "n" }, "yal", yank_buffer)
    vim.keymap.set({ "x", "o", "n" }, "yil", yank_buffer)

    -- Add a command to run tests from the current file
    vim.api.nvim_create_user_command("LeetTest", run_test_for_current_problem, {
        desc = "Run tests for the current problem"
    })

    vim.keymap.set("n", "<leader>t", run_test_for_current_problem)
end

return M
