require("nikola.set")
require("nikola.remap")
require("nikola.lazy")
require("nikola.leet").setup()
require("nikola.toggle_terminal").setup()

local autocmd = vim.api.nvim_create_autocmd

autocmd('LspAttach', {
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "<leader>k", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>a", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = e.buf })
        end
    end
})
