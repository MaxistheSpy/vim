local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)

-- harpoon picker
local normalize_list = function(t)
  local normalized = {}
  for _, v in pairs(t) do
    if v ~= nil then
      table.insert(normalized, v)
    end
  end
  return normalized
end

vim.keymap.set("n", "<C-e>", function()
  Snacks.picker({
    finder = function()
      local file_paths = {}
      local list = normalize_list(harpoon:list().items)
      for i, item in ipairs(list) do
        table.insert(file_paths, { text = item.value, file = item.value })
      end
      return file_paths
    end,
    win = {
    input = { keys = { ["<C-d>"] = { "harpoon_delete", mode = { "n", "i" } } } },
    list  = { keys = { ["<C-d>"] = { "harpoon_delete", mode = { "n", "i" } } } },
		},
    actions = {
      harpoon_delete = function(picker, item)
        local to_remove = item or picker:selected()
        harpoon:list():remove({ value = to_remove.text })
        harpoon:list().items = normalize_list(harpoon:list().items)
        picker:find({ refresh = true })
      end,
    },
  })end, { desc = "Open harpoon window" })
