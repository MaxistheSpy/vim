require("snacks").setup({
	quickfile = { enabled = true },
	bigfile = { enabled = true },
	input = { enabled = true },
	notifier = { enabled = true, timeout = 3000 },
	image = { enabled = true },
	statuscolumn = { enabled = true },
	indent = {
		enabled = true,
		animate = {
			duration = { step = 10, total = 100 },
			enabled = false,
		},
	},
	styles = {
		input = {
			icon = "",
		},
	},
	lazygit = {
		config = {
			git = { autoFetch = false },
		},
	},
	picker = {
		matcher = {
			frecency = true,
		},
		win = {
			input = {
				keys = {
					["<Esc>"] = { "close", mode = { "n", "i" } },
					["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
				},
			},
		},
		sources = {
			files = {
				exclude = { ".git" },
			},
		},
	},
})
local map = vim.keymap.set
map("n", "<leader>cR", function()
	Snacks.rename.rename_file()
end, { desc = "Rename file (LSP)" })
map("n", "<leader>un", function()
	Snacks.notifier.hide()
end, { desc = "Dismiss notifications" })
map("n", "<leader>.", function()
	Snacks.scratch()
end, { desc = "Scratch buffer" })
map("n", "<leader>S", function()
	Snacks.scratch.select()
end, { desc = "Select scratch" })
map("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>fn", function()
	Snacks.notifier.show_history()
end, { desc = "Notification history" })

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.inlay_hints():map("<leader>uh")

-- pickers
local map = vim.keymap.set
map("n", "<leader>fu", function()
	Snacks.picker.undo()
end, { desc = "Undo history" })
map("n", "<C-g>", function()
	Snacks.picker.git_files()
end, { desc = "Find files in git" })
map("n", "<leader>fg", function()
	Snacks.picker.grep()
end, { desc = "Live grep" })
map("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Help tags" })
map("n", "<leader>fk", function()
	Snacks.picker.keymaps()
end, { desc = "Find keymaps" })
map("n", "<leader>fs", function()
	Snacks.picker.lsp_workspace_symbols()
end, { desc = "Find symbols" })
map("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Find diagnostics" })
map("n", "<leader>fp", function()
	Snacks.picker.pickers()
end, { desc = "Find pickers" })
map("n", "<leader>ff", function()
	Snacks.picker.files()
end, { desc = "Find files (C-h toggles hidden)" })

-- stop distracting autocomplte on picker
vim.api.nvim_create_autocmd("FileType", {
	pattern = "snacks_picker_input",
	callback = function()
		vim.b.minicompletion_disable = true
	end,
})
-- auto open picker if no files selected
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argv(0) == "" then
			Snacks.picker.files({
				actions = {
					exit_nvim = function(picker)
						picker:close()
						vim.cmd.quit()
					end,
				},
				win = {
					input = {
						keys = { ["<C-c>"] = { "exit_nvim", mode = "i" }, ["<C-q>"] = { "exit_nvim", mode = "i" } },
						keys = { ["<C-q>"] = { "exit_nvim", mode = "i" } },
					},
				},
			})
		end
	end,
})

local terminal_fractions = { 0.33, 1.0 }

local function terminal_cycle_height(self)
	local fraction = vim.api.nvim_win_get_height(self.win) / vim.o.lines

	--[[ Find the list entry nearest the current height. Exact matching
	     would fail: the border adjustment below skews the measured
	     fraction off the preset values. ]]
	local nearest_index = 1
	for index, preset in ipairs(terminal_fractions) do
		if math.abs(preset - fraction) < math.abs(terminal_fractions[nearest_index] - fraction) then
			nearest_index = index
		end
	end

	-- step to the next entry, wrapping past the end
	local next_index = (nearest_index % #terminal_fractions) + 1
	vim.api.nvim_win_set_height(self.win, math.floor(vim.o.lines * terminal_fractions[next_index]) - 2) -- leave room for border
end

local terminal_win = {
	style = "float",
	anchor = "SW",
	row = vim.o.lines - 1,
	col = 0,
	width = 0,
	height = 0.33, -- default presentation: small (fractions < 1 are % of editor)
	border = "rounded",
	title = "   Neovim · Terminal ",
	title_pos = "center",
	keys = {
		cycle_size = {
			"<c-f>",
			terminal_cycle_height,
			mode = { "t" },
			desc = "Cycle terminal",
		},
	},
}

local function terminal_toggle(fraction)
	local term = Snacks.terminal.toggle(nil, { win = terminal_win })
	if term and term.win and vim.api.nvim_win_is_valid(term.win) then
		-- just became (or stayed) visible: apply requested size
		vim.api.nvim_win_set_height(term.win, math.floor(vim.o.lines * fraction) - 2)
	end
end

-- leader-t: small terminal — normal mode only (space-pause fix)
vim.keymap.set("n", "<leader>t", function()
	terminal_toggle(0.33)
end, { desc = "Terminal (small)" })
vim.keymap.set("n", "<leader>T", function()
	terminal_toggle(1.0)
end, { desc = "Terminal (full)" })

if vim.fn.executable("gh") == 1 then
	local api = Snacks.gh.api
	local fetch = api.fetch
	api.fetch = function(cb, opts)
		if opts.args and opts.args[2] == "list" then
			opts.fields = vim.tbl_filter(function(f)
				return f ~= "mergeable" and f ~= "mergeStateStatus"
			end, opts.fields)
		end
		return fetch(cb, opts)
	end

	local pr = {}

	local function parse(url)
		local repo, number = url:match("github%.com/([%w%-%._]+/[%w%-%._]+)/pull/(%d+)")
		return repo, tonumber(number)
	end

	local function discussion()
		vim.cmd.edit(("gh://%s/pr/%d"):format(pr.repo, pr.number))
	end

	local function files()
		Snacks.picker.gh_diff({ pr = pr.number, repo = pr.repo })
	end

	local function pick(after)
		Snacks.picker.gh_pr({
			state = "all",
			live = true,
			confirm = function(picker, item)
				picker:close()
				pr.repo, pr.number = item.repo, item.number
				after()
			end,
		})
	end

	local function pinned(fn)
		return function()
			if pr.number then
				fn()
			else
				pick(fn)
			end
		end
	end

	vim.keymap.set("n", "<leader>gp", function()
		pick(discussion)
	end, { desc = "Pin a PR" })
	vim.keymap.set("n", "<leader>gd", pinned(discussion), { desc = "Pinned PR: discussion" })
	vim.keymap.set("n", "<leader>gf", pinned(files), { desc = "Pinned PR: files" })
	vim.keymap.set("n", "<leader>gy", function()
		pr.repo, pr.number = parse(vim.fn.getreg("+"))
	end, { desc = "Pin PR from clipboard" })
end
