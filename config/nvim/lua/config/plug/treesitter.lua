require('orgmode').setup_ts_grammar()

require('nvim-treesitter.configs').setup({
	-- One of "all", "maintained" (parsers with maintainers), or a list of languages
	ensure_installed = {
       'c', 'cpp', 'cmake', 'css', 'elm', 'javascript', 
       'json', 'python', 'scss', 'sql', 'typescript', 
       'dockerfile', 'lua', 'yaml'
},

	-- Install languages synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- List of parsers to ignore installing
	ignore_install = {},

	highlight = {
		-- `false` will disable the whole extension
		enable = true,

		-- list of language that will be disabled
		disable = { 'markdown' },

		-- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = {'org'},
	},
})
