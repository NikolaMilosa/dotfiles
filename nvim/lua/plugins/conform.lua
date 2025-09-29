return {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                go = { "gofmt" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                rust = { "rustfmt" },
                python = function(bufnr)
                    if require("conform").get_formatter_info("ruff_format", bufnr).available then
                        return { "ruff_organize_imports", "ruff_fix", "ruff_format" }
                    else
                        vim.notify("Ruff format not found!", vim.log.levels.WARN)
                        return { "isort", "black" }
                    end
                end,
            },
            format_on_save = function(bufnr)
                return { timeout_ms = 3000, lsp_fallback = true }
            end
        })

        vim.keymap.set("n", "<leader>bf", function()
            require("conform").format({ bufnr = 0 })
        end)
    end,
}
