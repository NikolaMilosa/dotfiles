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

-- Check if there is a Rye project and source its virtual env if it exists
local sourceRyeVenvIfExists = function()
	-- Look for pyproject.toml (Rye projects always have one)
	local pyproject = vim.fn.glob(vim.fn.getcwd() .. "/pyproject.toml")
	if pyproject == "" then
		return
	end

	-- Optionally verify that it's a Rye-managed project
	local contains_rye = vim.fn.system("grep -q '\\[tool.rye\\]' " .. pyproject .. " && echo 1 || echo 0")
	if vim.fn.trim(contains_rye) ~= "1" then
		return
	end

	vim.notify("Found Rye project in root", vim.log.levels.INFO)

	-- Parse venv path from `rye show`
	local output = vim.fn.system("rye show")
	if vim.v.shell_error ~= 0 or output == "" then
		vim.notify("Failed to run 'rye show'", vim.log.levels.ERROR)
		return
	end

	local venv_path = string.match(output, "venv:%s*(%S+)")
	if not venv_path or venv_path == "" then
		vim.notify("Could not extract venv path from 'rye show'", vim.log.levels.ERROR)
		return
	end

	vim.notify("Using Rye venv: " .. venv_path, vim.log.levels.INFO)

	-- Set Python for LSP / plugins
	vim.g.python3_host_prog = venv_path .. "/bin/python"
	vim.env.VIRTUAL_ENV = venv_path
	vim.env.PATH = venv_path .. "/bin:" .. vim.env.PATH
end

return {
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },

		version = "1.*",

		opts = {
			keymap = { preset = "default" },

			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},

			--- for some reason it is not working properly
			---       documentation = { auto_show = true, auto_show_delay_ms = 50 },
			signature = { enabled = true, window = { show_documentation = true } },

			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 100 },
			},
		},
		opts_extend = { "sources.default" },
	},
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
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"saghen/blink.cmp",
		},
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			local servers = {
				{
					"lua_ls",
					{
						settings = {
							Lua = {
								diagnostics = {
									-- Get the language server to recognize the `vim` global
									globals = { "vim" },
								},
								workspace = {
									-- Make the server aware of Neovim runtime files
									library = vim.api.nvim_get_runtime_file("", true),
								},
							},
						},
					},
				},
				{
					"rust_analyzer",
					{
						cmd = vim.lsp.rpc.connect("127.0.0.1", 27631),
						settings = {
							["rust-analyzer"] = {
								lspMux = {
									version = "1",
									method = "connect",
									server = "rust-analyzer",
								},
							},
						},
					},
				},
				{ "gopls" },
				{ "csharp_ls" },
				{ "pyright" },
				{ "terraform_lsp " },
			}

			for _, lsp in pairs(servers) do
				local name, config = lsp[1], lsp[2] or {}
				vim.lsp.config(name, config)
				vim.lsp.config[name].capabilities = capabilities
				vim.lsp.enable(name)
			end

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
			sourceRyeVenvIfExists()
			vim.api.nvim_create_autocmd({ "DirChanged" }, {
				callback = function()
					sourceVenvIfExists()
					sourceRyeVenvIfExists()
				end,
			})
		end,
	},
}
