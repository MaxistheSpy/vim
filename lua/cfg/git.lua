vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Fugitive: git" })

local minidiff = require('mini.diff')
minidiff.setup({
	view = {
		style = 'sign',
		signs = { add = '┃', change = '┃', delete = '▾' },
	},
})

vim.keymap.set('n', '<leader>go', minidiff.toggle_overlay, { desc = 'Toggle diff overlay' })

--VC: all hunks in the repo into quickfix: the cross-file review map
vim.keymap.set('n', '<leader>gq', function()
	minidiff.export('qf')
	vim.cmd('copen')
end, { desc = 'All hunks -> quickfix' })

require('diffview').setup()
--VC: toggle: close the diffview tab if one is open, otherwise open one.
vim.keymap.set('n', '<leader>gv', function()
	if next(require('diffview.lib').views) == nil then
		vim.cmd('DiffviewOpen')
	else
		vim.cmd('DiffviewClose')
	end
end)
