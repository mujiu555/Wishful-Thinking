return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				---@type vim.lsp.Config
				["rust-analyzer"] = {
					settings = {
						["rust-analyzer"] = {
							cfg = {
								setTest = false,
							},
						},
					},
				},
			},
		},
	},
}
