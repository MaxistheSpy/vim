local opt = vim.opt
opt.winborder = "rounded" -- pretty popup boarders
opt.tabstop = 2           -- tabs are two columns
opt.shiftwidth = 2        -- sync << and >> to tabstop size
opt.ignorecase = true     --fixes weirdness surrounding case of :cmds
opt.wrap = false          -- stop linewrapping
opt.smartindent = true    -- let nvim try to do smart indenting
opt.updatetime = 200      -- things update in 200ms
