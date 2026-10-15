vim.loader.enable()
vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "
local modules = {
	"settings",
	"snacks",
	"color",
	"blink", -- must go before lsps
	"lsps",
	"fold",
	"oil",
	"eyeliner",
	"treesitter",
	"harpoon",
	"undotree",
	"git",
	"whichkey",
	"mini",
	"custom",
}
for _, name in ipairs(modules) do
	local ok, err = pcall(require, "cfg." .. name)
	if not ok then
		vim.notify(("cfg.%s failed: %s"):format(name, err), vim.log.levels.ERROR)
	end
end
