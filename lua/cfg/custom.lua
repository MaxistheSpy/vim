local map = vim.keymap.set

map("n", "<leader>mm", "<CMD>set mouse=<CR>", { desc = "disable mouse" })

map({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("x", "<leader>Y", '"+Y', { desc = "Yank lines (linewise) to clipboard" })
map({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
map("n", "<leader>P", '"0p', { desc = "Paste last yank" })
map("n", "<leader>ay", ":%y+<CR>", { desc = "Yank whole buffer to clipboard" })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 50 }) end,
})

-- local autocmd = vim.api.nvim_create_autocmd
-- restore line position on file open
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		local line = vim.fn.line "'\""
		if
				line > 1
				and line <= vim.fn.line "$"
				and vim.bo.filetype ~= "commit"
				and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
		then
			vim.cmd 'normal! g`"'
		end
	end,
})
