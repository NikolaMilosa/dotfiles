return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	setup = {
		select = {
			enable = true,
			-- Automatically jump forward to textobjects, similar to targets.vim
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
	},
}
