return {
	-- williamboman/ から mason-org/ に移管済み（旧名はリダイレクト依存で脆い）
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"graphql",
				"emmet_ls",
				"prismals",
				"pyright",
				"terraformls",
				"kotlin_language_server",
				"jsonls", -- JSON
				"yamlls", -- YAML
				"gopls", -- Go
				"buf_ls", -- Protobuf
				"bashls", -- Shell
				"dockerls", -- Dockerfile
				"docker_compose_language_service", -- docker-compose
				"marksman", -- Markdown
				"rust_analyzer", -- Rust
				"clangd", -- C/C++
				"taplo", -- TOML
				"sqlls", -- SQL
			},
			-- NOTE: automatic_installation は mason-lspconfig v2.0 で削除済み
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"pylint", -- python linter
				"eslint_d", -- js linter
				"tflint", -- tflint
				"yamlfmt", -- yaml formatter
				"yamllint", -- yaml lintter
			},
		})
	end,
}
