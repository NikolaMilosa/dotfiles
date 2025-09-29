return {
    'lewis6991/gitsigns.nvim',
    config = function()
        require("gitsigns").setup {
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                map("n", "<leader>gb", gitsigns.blame)
                map("n", "<leader>hr", gitsigns.reset_hunk)
                map({ 'o', 'x' }, 'ih', function()
                    gitsigns.select_hunk()
                end)
            end
        }
    end
}
