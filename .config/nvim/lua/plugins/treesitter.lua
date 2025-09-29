return {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        require("nvim-treesitter.configs").setup {
            ensure_installed = { "rust", "lua", "markdown" },
            sync_install = false,
            auto_install = true,
            highlight = { enable = true,
                additional_vim_regex_highlighting = false },
            ignore_install = {},
            modules = {},
            incremental_selection = { enable = true },
            textobjects = {
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
                    }
                }
            }
        }
    end
}
