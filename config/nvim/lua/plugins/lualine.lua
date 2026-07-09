-- Responsive statusline: full detail above 80 columns, essentials only below it.
local WIDE_THRESHOLD = 80

local function is_wide()
	return vim.o.columns > WIDE_THRESHOLD
end

local DIAGNOSTIC_ICONS = {
	error = "\u{f057} ", --  nf-fa-times_circle
	warn = "\u{f529} ", --  nf-oct-alert
	info = "\u{f05a} ", --  nf-fa-info_circle
	hint = "\u{f0eb} ", --  nf-fa-lightbulb_o
}

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		options = {
			theme = "dracula",
			icons_enabled = true,
			component_separators = { left = "\u{e0b1}", right = "\u{e0b3}" },
			section_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },
			globalstatus = true,
			extensions = { "neo-tree", "lazy" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				{ "branch", icon = "", cond = is_wide },
				{
					"diff",
					symbols = { added = "+", modified = "~", removed = "-" },
					cond = is_wide,
				},
				{
					"diagnostics",
					symbols = DIAGNOSTIC_ICONS,
					cond = is_wide,
				},
			},
			lualine_c = {
				{ "filename", symbols = { modified = " ●", readonly = " " } },
			},
			lualine_x = {
				{ "filetype", cond = is_wide },
			},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	},
}
