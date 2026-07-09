return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons", -- optional, but recommended
	},
	lazy = false, -- neo-tree will lazily load itself
	keys = {
		{ "<leader>w", ":Neotree toggle float<CR>", silent = true, desc = "Float File Explorer" },
		{ "<leader>e", ":Neotree toggle position=left<CR>", silent = true, desc = "Left File Explorer" },
		{ "<leader>ngs", ":Neotree float git_status<CR>", silent = true, desc = "Neotree Open Git Status Window" },
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			filesystem = {
				bind_to_cwd = true,
				follow_current_file = {
					enabled = true,
				},
			},
		})
	end,
}
