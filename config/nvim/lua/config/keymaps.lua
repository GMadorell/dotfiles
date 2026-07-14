-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- As we set leader to space, disable normal space behaviour on Normal and Visual modes
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

local opts = { noremap = true, silent = true }

-- use leader and yank commands to copy to system clipboard
vim.keymap.set("v", "<leader>yy", '"+y', opts)
vim.keymap.set("n", "<leader>Y", '"+yg_', opts)
vim.keymap.set("n", "<leader>yy", '"+yy', opts)

-- use leader and paste commands to paste from system clipboard
vim.keymap.set("n", "<leader>p", '"+p', opts)
vim.keymap.set("n", "<leader>P", '"+P', opts)
vim.keymap.set("v", "<leader>p", '"+p', opts)
vim.keymap.set("v", "<leader>P", '"+P', opts)

-- ctrl + s to save the file
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", opts)
-- ctrl + q to quit the file
vim.keymap.set("n", "<C-q>", "<cmd>q<CR>", opts)
-- ctrl + a to select the whole file
vim.keymap.set("n", "<C-a>", "ggVG", opts)
-- x deletes char without putting into register
vim.keymap.set("n", "x", '"_x', opts)

-- Find and center
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Resize with arrows
vim.keymap.set("n", "<Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<Right>", ":vertical resize +2<CR>", opts)

-- Buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", opts) -- move buffer forward (eg next file)
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", opts) -- move buffer bw (eg prev file)
vim.keymap.set("n", "<C-i>", "<C-i>", opts) -- to restore jump forward
vim.keymap.set("n", "<leader>x", ":Bdelete!<CR>", opts) -- close buffer
vim.keymap.set("n", "<leader>b", "<cmd> enew <CR>", opts) -- new buffer

-- Window management
vim.keymap.set("n", "<leader>v", "<C-w>v", opts) -- split window vertically
vim.keymap.set("n", "<leader>h", "<C-w>s", opts) -- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", opts) -- make split windows equal width & height
vim.keymap.set("n", "<leader>xs", ":close<CR>", opts) -- close current split window

-- Navigate between splits
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", opts)
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", opts)
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", opts)
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", opts)

-- Tabs
vim.keymap.set("n", "<leader>tt", ":tabnew<CR>", opts) -- open new tab
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", opts) -- close current tab
vim.keymap.set("n", "<leader>th", ":tabn<CR>", opts) --  go to next tab
vim.keymap.set("n", "<leader>tl", ":tabp<CR>", opts) --  go to previous tab

-- Toggle line wrapping
vim.keymap.set("n", "<leader>lw", "<cmd>set wrap!<CR>", opts)

-- Toggle autocompletion (blink.cmp) on/off globally
vim.keymap.set("n", "<leader>tc", function()
	vim.g.blink_cmp_enabled = (vim.g.blink_cmp_enabled == false)
	vim.notify("Autocompletion " .. (vim.g.blink_cmp_enabled == false and "disabled" or "enabled"))
end, opts)

-- Toggle markdown rendering (render-markdown.nvim) on/off
vim.keymap.set("n", "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", opts)

-- Stay in visual mode when indenting or de-indenting
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Keep last yanked when pasting over any other text (eg visual mode)
vim.keymap.set("v", "p", '"_dP', opts)

-- Make escape clear last search result highlight
vim.keymap.set("n", "<Esc>", "<Esc>:nohlsearch<CR>", opts)

-- Yank current line/selection with path, treesitter breadcrumb, and code fence (for LLM context)
vim.keymap.set({ "n", "v" }, "<leader>yc", function()
	require("util.yank_context").yank()
end, opts)
