return {
	"karb94/neoscroll.nvim",
	config = function()
		local neoscroll = require("neoscroll")
		neoscroll.setup({
			duration_multiplier = 0.5,
			-- <C-d>/<C-u> get custom mappings below so they can recenter after scrolling
			mappings = { "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
			post_hook = function(info)
				if info == "center" then
					vim.cmd("normal! zz")
				end
			end,
		})

		local keymap = {
			["<C-d>"] = function()
				neoscroll.ctrl_d({ duration = 250, info = "center" })
			end,
			["<C-u>"] = function()
				neoscroll.ctrl_u({ duration = 250, info = "center" })
			end,
		}
		for key, func in pairs(keymap) do
			vim.keymap.set({ "n", "v", "x" }, key, func)
		end
	end,
}
