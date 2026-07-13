return {
  "yetone/avante.nvim",
  build = "make",
  event = "VeryLazy",
  version = false,
  opts = {
    -- ACP provider: delegates to the `claude` CLI, reusing its Pro/Max login.
    provider = "claude-code",
    acp_providers = {
      -- avante spawns ACP agents with only PATH set; claude needs HOME/USER to find its login.
      ["claude-code"] = {
        env = { HOME = os.getenv("HOME"), USER = os.getenv("USER") },
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    "MeanderingProgrammer/render-markdown.nvim",
    "HakonHarnes/img-clip.nvim",
  },
}
