-- Provides `vim` global + full Neovim API/plugin types to lua_ls when
-- editing this config, instead of hardcoding a globals list.
return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	},
}
