return {
	"selimacerbas/mdkite.nvim",
	dependencies = { "selimacerbas/kitehost.nvim" },
	ft = { "markdown" },
	config = function()
		require("mdkite").setup({})

		vim.keymap.set("n", "<leader>mps", "<cmd>MdKite start<cr>", { desc = "Markdown: Start preview" })
		vim.keymap.set("n", "<leader>mpS", "<cmd>MdKite stop<cr>", { desc = "Markdown: Stop preview" })
		vim.keymap.set("n", "<leader>mpr", "<cmd>MdKite refresh<cr>", { desc = "Markdown: Refresh preview" })
	end,
}
