function setColorScheme(color)
  defaultColor = "rose-pine"
  default_color = "rose-pine"
  color = color or default_color
  vim.cmd.colorscheme(color)

  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

setColorScheme()
