local parsers = { "rust", "markdown", "markdown_inline" }

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install(parsers)

		-- Highlighting isn't auto-enabled by nvim-treesitter anymore; start it
		-- ourselves whenever a parser is available for the buffer's filetype.
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(args.match)
				if lang and vim.treesitter.language.add(lang) then
					vim.treesitter.start()
				end
			end,
		})
	end,
}
