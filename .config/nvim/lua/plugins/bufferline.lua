return {
    'akinsho/bufferline.nvim',
    version = "v4.9",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        require("bufferline").setup {
            options = {
                buffer_close_icon = '',
                close_icon = '',
                diagnostics = "nvim_lsp",
                custom_filter = function(buf_number, buf_numbers)
                    local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf_number })
                    -- Don't show termianls
                    if buftype == "terminal" then
                        return false
                    end

                    local buf_path = vim.api.nvim_buf_get_name(buf_number)
                    if vim.fn.isdirectory(buf_path) == 1 then
                        return false
                    end

                    return true
                end
            }
        }

        vim.keymap.set("n", "e", ":BufferLineCycleNext<cr>")
        vim.keymap.set("n", "q", ":BufferLineCyclePrev<cr>")
        vim.keymap.set("n", "<leader>w", ":bdelete<cr>")
    end
}
