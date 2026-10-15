require("lazydev").setup({
	library = { { path = "snacks.nvim", words = { "Snacks" } } },
})
require("conform").setup({
	formatters_by_ft = { lua = { "stylua" }, meson = { "meson" } },
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})
require("treesj").setup({ max_join_length = 100 })
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = { command = "clippy" },
			workspace = { symbol = { search = { kind = "all_symbols", limit = 1024 } } },
		},
	},
})
vim.lsp.config("nixd", {
	before_init = function(_, config)
		local flake_dir = vim.fs.root(config.root_dir or vim.uv.cwd(), "flake.nix")
		if not flake_dir then
			local chezmoi = vim.fn.systemlist({ "chezmoi", "source-path" })[1]
			if vim.v.shell_error == 0 and vim.uv.fs_stat(vim.fs.joinpath(chezmoi, "flake.nix")) then
				flake_dir = chezmoi
			end
		end
		if flake_dir then
			config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
				nixd = {
					nixpkgs = {
						expr = string.format('import (builtins.getFlake "%s").inputs.nixpkgs { }', flake_dir),
					},
				},
			})
		end
	end,
	settings = {
		nixd = {
			formatting = { command = { "nixfmt" } },
			nixpkgs = { expr = "import <nixpkgs> { }" }, -- fallback when no flake found
		},
	},
})
vim.lsp.config("nil_ls", {
	settings = {
		["nil"] = {
			diagnostics = { ignored = {} }, -- populate with overlapping kinds, see below
		},
	},
})
vim.lsp.enable({ "lua_ls", "clangd", "nil_ls", "nixd", "rust_analyzer", "basedpyright" })
vim.opt.signcolumn = "yes:1" -- prealocate sign space to fix wobbly lines

-- hover on diagnostic
vim.diagnostic.config({
	virtual_lines = { current_line = true },
})
-- vim.api.nvim_create_autocmd({ 'CursorHold' }, {
-- 	group = vim.api.nvim_create_augroup("diagnostic_hover", {}),
-- 	callback = function()
-- 		local opts = {
-- 			focusable = false,
-- 			scope = 'line',
-- 			close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter' },
-- 		}
-- 		vim.diagnostic.open_float(nil, opts)
-- 	end
-- }
-- )
-- disable diagnostics on insert
vim.api.nvim_create_autocmd("InsertEnter", {
	group = vim.api.nvim_create_augroup("diagnostic_off_insert", {}),
	callback = function()
		vim.diagnostic.enable(false)
	end,
})
-- reenable diagnostics on insert exit
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		vim.diagnostic.enable(true)
	end,
	group = vim.api.nvim_create_augroup("diagnostic_on_insert", {}),
})

-- ## LSP: format on save + keymaps
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end
		if client.name == "lua_ls" then
			client.server_capabilities.documentFormattingProvider = nil
			client.server_capabilities.documentRangeFormattingProvider = nil
		end
		if client.name == "nil_ls" then
			client.server_capabilities.completionProvider = nil
			client.server_capabilities.hoverProvider = nil
			client.server_capabilities.documentFormattingProvider = nil
			client.server_capabilities.documentRangeFormattingProvider = nil
			client.server_capabilities.definitionProvider = nil
			client.server_capabilities.semanticTokensProvider = nil
		end
		if client.name == "nixd" then
			client.server_capabilities.renameProvider = nil
		end

		-- buffer-local mapping helper
		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
		end

		map("n", "gd", vim.lsp.buf.definition, "Go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
		map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
		map("i", "<C-s>", vim.lsp.buf.signature_help, "Signature help")
		map("n", "<leader>q", vim.diagnostic.setloclist, "List diagnostics")
		map("n", "<leader>d", function()
			vim.diagnostic.open_float()
		end, "Focus diagnostic float")

		map("n", "<leader>hh", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }))
		end, "Toggle inlay hints")

		-- format the buffer manually
		map("n", "<leader>F", function()
			local ok, c = pcall(require, "conform")
			if ok then
				c.format({ async = true, lsp_format = "fallback" })
			else
				vim.lsp.buf.format({ async = true })
			end
		end, "Format buffer")

		-- format on save (only if this client can format)
		if client:supports_method("textDocument/formatting") then
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("lsp-format-" .. args.buf .. "-" .. client.id, { clear = true }),
				buffer = args.buf,
				callback = function()
					vim.lsp.buf.format({ async = false, id = client.id })
				end,
			})
		end
	end,
})

-- -- enable autocompletion
--  vim.api.nvim_create_autocmd("LspAttach", {
-- 	group = vim.api.nvim_create_augroup("lsp_autocomplete", {}),
-- 	callback = function(args)
-- 		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
-- 		if client:supports_method("textDocument/completion") then
-- 			-- Optional: trigger autocompletion on EVERY keypress. May be slow!
-- 			local chars = {}
-- 			for i = 32, 126 do
-- 				table.insert(chars, string.char(i))
-- 			end
-- 			clien.server_capabilities.completionProvider.triggerCharacters = chars
-- 			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
-- 		end
-- 	end,
-- })

-- IMPORTANT autocompletion wont add text unless confirmed
vim.cmd([[set completeopt+=menuone,noselect,popup]])
