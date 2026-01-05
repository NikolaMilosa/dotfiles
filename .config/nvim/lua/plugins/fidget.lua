return {
    "j-hui/fidget.nvim",
    version = "v1.6",
    config = function()
        require("fidget").setup {
            notification = {
                override_vim_notify = true,
            }
        }
    end
}
