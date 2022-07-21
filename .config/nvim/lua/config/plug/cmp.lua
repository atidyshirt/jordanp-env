-- Setup nvim-cmp.
local cmp = require('cmp')
local keymap = require('keymap')

cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn['UltiSnips#Anon'](args.body)
		end,
	},
	mapping = keymap.cmp_mappings,
	sources = cmp.config.sources({
		{ name = 'ultisnips', priority = 1 },
		{ name = 'nvim_lsp', priority = 2 },
		{ name = 'orgmode' },
	}, {
		{ name = 'buffer' },
		{ name = 'path' },
	}),
})
