return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		delay = 1000,
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
