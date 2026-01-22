local M = {}

-- Run a shell command and capture stdout
local function cmd_output(cmd)
	local handle = io.popen(cmd)
	if not handle then
		return nil
	end
	local result = handle:read("*a")
	handle:close()
	return vim.trim(result)
end

-- Safely run a system command
local function system_ok(cmd)
	local ok, _, code = os.execute(cmd)
	return ok
end

-- Core function
local send_file = function(direction)
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("No file open", vim.log.levels.ERROR)
		return
	end

	local line = vim.api.nvim_win_get_cursor(0)[1]
	local current_pane = cmd_output("tmux display -p '#{pane_id}'")
	if not current_pane or current_pane == "" then
		vim.notify("Not inside tmux", vim.log.levels.ERROR)
		return
	end

	-- Try to select the pane in the given direction
	local ok = system_ok("tmux select-pane " .. direction .. " 2>/dev/null")
	if not ok then
		vim.notify("No pane in direction " .. direction, vim.log.levels.WARN)
		return
	end

	local target_pane = cmd_output("tmux display -p '#{pane_id}'")
	if target_pane == current_pane then
		vim.notify("No pane in direction " .. direction, vim.log.levels.WARN)
		return
	end

	-- Get TTY of target pane
	local tty = cmd_output("tmux display -p -t " .. target_pane .. " '#{pane_tty}' 2>/dev/null")
	if not tty or tty == "" then
		vim.notify("Invalid target pane", vim.log.levels.ERROR)
		return
	end

	-- Get most recent process running in target pane
	local pid = cmd_output(string.format("ps -o pid= --sort=-pid --tty '%s' | head -n1", tty))
	local cmd = cmd_output(string.format("ps -o comm= -p %s 2>/dev/null", pid))

	local actual_path = vim.fn.fnamemodify(file, ":p")

	if cmd == "nvim" then
		os.execute(string.format("tmux send-keys -t %s Escape", target_pane))
		os.execute(string.format("tmux send-keys -t %s ':edit %s' Enter", target_pane, actual_path))
		os.execute(string.format("tmux send-keys -t %s '%sgg'", target_pane, line))
	elseif cmd == "zsh" then
		-- Get current Neovim working directory
		local cwd = vim.fn.getcwd()
		-- Escape quotes and spaces for shell safety
		local safe_cwd = cwd:gsub("([\"' ])", "\\%1")
		local safe_path = actual_path:gsub("([\"' ])", "\\%1")
		-- Send a command to zsh pane: open nvim with same cwd and file
		local open_cmd = string.format("cd %s && nvim %s", safe_cwd, safe_path)
		os.execute(string.format("tmux send-keys -t %s '%s' Enter", target_pane, open_cmd))
		os.execute(string.format("tmux send-keys -t %s '%sgg'", target_pane, line))
	else
		local full_cmd = cmd_output(string.format("ps -o args= -p %s", pid))
		vim.notify("Unsupported program in target pane: " .. (full_cmd or "unknown"), vim.log.levels.WARN)
	end

	-- Return to original pane
	os.execute(string.format("tmux select-pane -t %s", current_pane))

	-- Close the current buffer
	vim.api.nvim_buf_delete(0, {})
end

function M.setup()
	vim.keymap.set("n", "<leader><leader>h", function()
		send_file("-L")
	end, { desc = "Send file left" })
	vim.keymap.set("n", "<leader><leader>j", function()
		send_file("-D")
	end, { desc = "Send file down" })
	vim.keymap.set("n", "<leader><leader>k", function()
		send_file("-U")
	end, { desc = "Send file up" })
	vim.keymap.set("n", "<leader><leader>l", function()
		send_file("-R")
	end, { desc = "Send file right" })
end

return M
