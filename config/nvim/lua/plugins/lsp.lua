vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
  callback = function(args)
    local bufopts = { noremap = true, silent = true, buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
  end,
})

-- rust-analyzer panics on half-typed code (e.g. partial println!) and nvim
-- surfaces each one as a multi-line ERROR, blocking typing with a hit-enter
-- prompt. Send those to :LspLog instead; other notifications pass through.
local notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == "string" and msg:find("^rust_analyzer: %-32603: request handler panicked") then
    vim.lsp.log.warn(msg)
    return
  end
  return notify(msg, level, opts)
end

-- Isolate rust-analyzer's background cargo check/build script runs from the
-- shared CARGO_TARGET_DIR (see rust.zsh) so they don't contend on fingerprint
-- state with manually run cargo test/build.
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = { targetDir = true },
    },
  },
})

return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = { "rust_analyzer", "lua_ls", "taplo" },
  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },
}
