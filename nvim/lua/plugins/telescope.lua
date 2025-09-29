return {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.8",

    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        local telescopeConfig = require("telescope.config")
        local actions = require("telescope.actions")

        local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

        table.insert(vimgrep_arguments, "--hidden")
        table.insert(vimgrep_arguments, "--glob")
        table.insert(vimgrep_arguments, "!**/.git/*")

        require('telescope').setup({
            defaults = {
                vimgrep_arguments = vimgrep_arguments,
                mappings = {
                    i = {
                        ["<esc>"] = actions.close,
                        ["<C-u>"] = false
                    },
                }
            },
            pickers = {
                find_files = {
                    find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "--no-ignore", "--glob", "!target/*" },
                }
            }
        })

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.git_files, {})
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>l', builtin.live_grep, { noremap = true })
        vim.keymap.set('n', '<leader>hh', builtin.help_tags, { noremap = true })
        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols)
        vim.keymap.set('n', '<leader>fr', builtin.lsp_references)
        vim.keymap.set('n', '<leader>.', function() builtin.find_files({ cwd = vim.fn.expand('%:p:h') }) end)
    end
}
