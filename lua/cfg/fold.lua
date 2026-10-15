-- fold stuff
vim.opt.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99 -- open all folds when a buffer loads
vim.opt.foldnestmax = 4   -- any nesting beyond 4 is folded/unfoled together
vim.o.foldtext = ""       -- folded line keeps its syntax highlighting

-- require('ufo').setup()

-- enable treesitter based folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- enable folding
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.supports_method 'textDocument/foldingRange' then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldmethod = 'expr'
			vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
			vim.notify 'Enable folding with LSP'
		end
	end,
})
