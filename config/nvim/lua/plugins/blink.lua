-- blink is used for autocompletion

local function in_comment()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local parser = vim.treesitter.get_parser(0)
	if not parser then
		return false
	end
	parser:parse()
	local node = vim.treesitter.get_node({ pos = { row - 1, math.max(0, col - 1) } })
	if not node then
		return false
	end
	while node do
		if node:type() == "comment" then
			return true
		end
		node = node:parent()
	end
	return false
end

return {
	"saghen/blink.cmp",
	dependencies = { "folke/lazydev.nvim" },

	version = "1.*",

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		enabled = function()
			-- Disable the completions in some file types and when in comment
			local ft = vim.bo.filetype
			if ft == "markdown" or ft == "text" then
				return false
			end
			return not in_comment()
		end,
		-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
		-- 'super-tab' for mappings similar to vscode (tab to accept)
		-- 'enter' for enter to accept
		-- 'none' for no mappings
		--
		-- All presets have the following mappings:
		-- C-space: Open menu or open docs if already open
		-- C-n/C-p or Up/Down: Select next/previous item
		-- C-e: Hide menu
		-- C-k: Toggle signature help (if signature.enabled = true)
		--
		-- See :h blink-cmp-config-keymap for defining your own keymap
		keymap = { preset = "default" },

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		},

		-- (Default) Only show the documentation popup when manually triggered
		completion = { documentation = { auto_show = false } },

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				lua = { "lazydev", "lsp", "path", "snippets", "buffer" },
			},
			providers = {
				lazydev = { name = "LazyDev", module = "lazydev.integrations.blink" },
			},
		},

		-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
		-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- See the fuzzy documentation for more information
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
