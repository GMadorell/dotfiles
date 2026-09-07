-- Metals (Scala LSP) isn't managed by mason-lspconfig (no server mapping);
-- nvim-metals bootstraps and manages the Metals server itself.
return {
  "scalameta/nvim-metals",
  ft = { "scala", "sbt" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local metals_config = require("metals").bare_config()
    metals_config.init_options.statusBarProvider = "off"

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt" },
      group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
    })
  end,
}
