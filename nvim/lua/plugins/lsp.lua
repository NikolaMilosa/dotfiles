-- Check if there is a `./poetry.lock` and source env if it exists
local sourceVenvIfExists = function()
    local match = vim.fn.glob(vim.fn.getcwd() .. "/poetry.lock")
    -- Return if there are no matches
    if match == "" then
        return
    end

    vim.notify("Found poetry.lock in root", vim.log.levels.INFO)
    local venv_path = vim.fn.trim(vim.fn.system("poetry env info --path"))
    if vim.v.shell_error ~= 0 or venv_path == "" then
        vim.notify("Could not get poetry venv path", vim.log.levels.ERROR)
        return
    end

    vim.notify("Using Poetry venv: " .. venv_path, vim.log.levels.INFO)

    -- Set Python for LSP / plugins
    vim.g.python3_host_prog = venv_path .. "/bin/python"
    vim.env.VIRTUAL_ENV = venv_path
    vim.env.PATH = venv_path .. "/bin:" .. vim.env.PATH
end

return {
    {
        'saghen/blink.cmp',
        dependencies = { 'rafamadriz/friendly-snippets' },

        version = '1.*',

        opts = {
            keymap = { preset = 'default' },

            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'mono'
            },

            --- for some reason it is not working properly
            ---       documentation = { auto_show = true, auto_show_delay_ms = 50 },
            signature = { enabled = true, window = { show_documentation = true } },

            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 100 },
            }

        },
        opts_extend = { "sources.default" }
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
            'saghen/blink.cmp',
        },
        config = function()
            local lspconfig = require("lspconfig")
            local configs = require("lspconfig.configs")

            local capabilities = require("blink.cmp").get_lsp_capabilities()

            -- lua setup --
            lspconfig.lua_ls.setup {
                capabilities = capabilities }

            -- rust setup --
            if not configs.rust_multiplex then
                configs.rust_multiplex = {
                    default_config = {
                        cmd = { "/usr/local/bin/ra-multiplex", "client", "--server-path", "rust-analyzer" },
                        filetype = { "rust" },
                        root_dir = lspconfig.util.root_pattern("Cargo.toml"),
                        settings = {},
                    }
                }
            end
            lspconfig.rust_multiplex.setup {
                capabilities = capabilities }

            lspconfig.gopls.setup { capabilities = capabilities }

            lspconfig.csharp_ls.setup { capabilities = capabilities }

            lspconfig.pyright.setup { capabilities = capabilities }

            lspconfig.terraform_lsp.setup { capabilities = capabilities }

            vim.diagnostic.config({
                virtual_text = {
                    prefix = "●", -- could be "■", "▎", "x"
                    spacing = 3,
                    severity = { min = vim.diagnostic.severity.WARN },
                },
                signs = {
                    severity = { min = vim.diagnostic.severity.WARN },
                },
                underline = {
                    severity = { min = vim.diagnostic.severity.WARN },
                },
                update_in_insert = false,
                severity_sort = true,
                float = {
                    focusable = false,
                    severity = { min = vim.diagnostic.severity.WARN },
                    style = "minimal",
                    border = "rounded",
                    source = true,
                    header = "",
                    prefix = "",
                },
            })

            -- Try source on init
            sourceVenvIfExists()
            vim.api.nvim_create_autocmd({ "DirChanged" }, {
                callback = sourceVenvIfExists
            })
        end,
    }
}
