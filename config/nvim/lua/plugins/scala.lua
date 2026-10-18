-- Metals (Scala LSP) isn't managed by mason-lspconfig (no server mapping);
-- nvim-metals bootstraps and manages the Metals server itself.
return {
  "scalameta/nvim-metals",
  ft = { "scala", "sbt" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local metals_config = require("metals").bare_config()
    metals_config.init_options.statusBarProvider = "off"

    -- Format on save via Metals (scalafmt; uses project's .scalafmt.conf).
    local format_group = vim.api.nvim_create_augroup("metals-format", { clear = true })
    metals_config.on_attach = function(client, bufnr)
      if client:supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = format_group,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ bufnr = bufnr, id = client.id, async = false })
          end,
        })
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt" },
      group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
    })
  end,
}
