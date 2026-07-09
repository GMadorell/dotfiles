vim.wo.number = true -- Make line numbers visible
vim.o.relativenumber = true -- Set relative numbered lines
vim.o.signcolumn = 'yes:1' -- Always reserve a fixed-width sign column so diagnostics don't shift the gutter

vim.o.cursorline = true -- highlight the current line
vim.opt.termguicolors = true -- enable more colors
vim.o.splitbelow = true -- force all horizontal splits to go below current window
vim.o.splitright = true -- force all vertical splits to go to the right of current window

vim.o.wrap = false -- Don't wrap long lines
vim.o.linebreak = true -- Don't split words
vim.o.whichwrap = 'bs<>[]hl' -- which "horizontal" keys are allowed to travel to prev/next line
vim.o.smartindent = true -- Try to easen work when indenting (eg use other lines indent when new line)
vim.o.scrolloff = 4 -- minimal number of screen lines to keep above and below the cursor
vim.o.sidescrolloff = 8 -- minimal number of screen columns either side of cursor if wrap is `false`

vim.o.undofile = true -- Save undo history
vim.o.mouse = 'a' -- Enable mouse mode, WATCH THE WORLD BURN 🌍🔥
vim.o.completeopt = 'menuone,noselect' -- Set completeopt to have a better completion experience

vim.o.ignorecase = true -- Case-insensitive search unless \C or capital in search
vim.o.smartcase = true -- Case-insensitive search too

vim.o.expandtab = true -- Prefer tabs over spaces
vim.o.shiftwidth = 2 -- Number spaces per indentation level
vim.o.tabstop = 2 -- N spaces per tab
vim.o.softtabstop = 2 -- N spaces per tab
