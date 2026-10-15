require("blink.cmp").setup({
	keymap = { preset = "default" },
	sources = {
		default = { "lazydev", "lsp", "path", "snippets", "buffer" },
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
			},
		},
	},
	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 300 },
	},
	signature = { enabled = true },
})
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
})
