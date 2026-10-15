vim.keymap.set("n", "<leader>ut", vim.cmd.UndotreeToggle, { desc = "Undotree: Toggle" })

vim.opt.undofile = true
-- make undodir user only WARN: for new systems nvim must first create undo dir for this to apply
vim.uv.fs_chmod(vim.fn.stdpath("state") .. "/undo", tonumber("700", 8))
--
vim.opt.shada = "'10,<50,s10,h"
vim.lsp.log.set_level("debug")


-- before opening secure file disable persistance
vim.api.nvim_create_autocmd("BufReadPre", {
	callback = function(ev)
		local perm = vim.fn.getfperm(ev.match)
		if perm ~= "" and perm:sub(7, 7) == "-" then
			vim.opt_local.undofile = false
			vim.opt_local.swapfile = false
			vim.opt_local.writebackup = false
			vim.opt.shada = "'10,<0,s10,h"
			vim.lsp.log.set_level("off")
		end
	end,
})
