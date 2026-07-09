return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = { "rust_analyzer", "lua_ls" },
    handlers = {
      function(server_name)
        require("lspconfig")[server_name].setup({
          on_attach = function(client, bufnr)
            local bufopts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
            vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
          end,
        })
      end,
    },
  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },
}
