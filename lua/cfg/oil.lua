require("oil").setup(
	{
		lsp_file_methods = {
			enabled = true,
			timeout_ms = 1000,
			autosave_changes = false,
		},
	}
)

vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open oil" })
