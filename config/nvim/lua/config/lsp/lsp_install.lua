local lsp_installer = require "nvim-lsp-installer"

lsp_installer.setup({
    ensure_installed = {
		"pyright",
		"tsserver",
		"bashls",
		"ccls",
		"clangd",
		"angularls",
	},
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})

local servers = { 
    "pyright", "tsserver", "bashls", "ccls", "clangd", "angularls" 
}
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {}
end
