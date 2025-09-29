return {
    'smoka7/hop.nvim',
    version = "v2.7",
    config = function()
        local hop = require("hop")
        local directions = require('hop.hint').HintDirection

        hop.setup {}

        vim.keymap.set('', 'gw', hop.hint_words)
    end
}
