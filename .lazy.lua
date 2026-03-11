return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				---@type vim.lsp.Config
				tinymist = {
					settings = {
						exportTarget = "html",
					},
				},
			},
		},
	},
}
