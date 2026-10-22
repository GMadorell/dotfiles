-- Responsive statusline: full detail above 80 columns, essentials only below it.
local WIDE_THRESHOLD = 80

local function is_wide()
	return vim.o.columns > WIDE_THRESHOLD
end

-- Path shows up to MAX_PATH_PARTS trailing segments, dropping leading ones until it
-- fits PATH_WIDTH_RATIO of the screen, so the bar always keeps some breathing room.
local MAX_PATH_PARTS = 4
local PATH_WIDTH_RATIO = 0.4

local function trailing_path()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return "[No Name]"
	end
	local parts = vim.split(vim.fn.fnamemodify(name, ":~:."), "/", { trimempty = true })
	local budget = math.floor(vim.o.columns * PATH_WIDTH_RATIO)
	local path = parts[#parts]
	for count = math.min(MAX_PATH_PARTS, #parts), 2, -1 do
		local candidate = table.concat(parts, "/", #parts - count + 1)
		if count < #parts then
			candidate = "…/" .. candidate
		end
		if vim.fn.strdisplaywidth(candidate) <= budget then
			path = candidate
			break
		end
	end
	if vim.bo.modified then
		path = path .. " ●"
	end
	if vim.bo.readonly or not vim.bo.modifiable then
		path = path .. " "
	end
	return path
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
				trailing_path,
			},
			lualine_x = {
				{ "filetype", cond = is_wide },
			},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	},
}
