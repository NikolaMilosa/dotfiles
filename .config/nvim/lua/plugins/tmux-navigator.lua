return {
	"christoomey/vim-tmux-navigator",
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
		"TmuxNavigatorProcessList",
	},
	init = function()
		vim.g.tmux_navigator_no_mappings = 1
	end,
	keys = {
		{ "<a-h>", "<cmd>TmuxNavigateLeft<cr>" },
		{ "<a-j>", "<cmd>TmuxNavigateDown<cr>" },
		{ "<a-k>", "<cmd>TmuxNavigateUp<cr>" },
		{ "<a-l>", "<cmd>TmuxNavigateRight<cr>" },
		{ "<a-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
	},
}
