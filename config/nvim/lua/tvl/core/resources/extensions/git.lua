local Util = require("tvl.util")
local Icons = require("tvl.core.icons")

local function get_signs()
  local signs = {}
  if vim.g.nerd_font_enabled == true then
    signs = Icons.gitsigns
  else
    signs = Icons.gitsigns_text
  end
  return {
    add = { text = signs.add },
    change = { text = signs.change },
    delete = { text = signs.delete },
    topdelhfe = { text = signs.topdelhfe },
    changedelete = { text = signs.changedelete },
    untracked = { text = signs.untracked },
  }
end

return {
  { "tpope/vim-fugitive" },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = get_signs(),
      signcolumn = vim.g.nerd_font_enabled,
      current_line_blame = false,
      current_line_blame_opts = {
        delay = 300,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      preview_config = {
        border = Util.generate_borderchars("thick", "tl-t-tr-r-bl-b-br-l"),
      },
    },
    keys = {
      { "<leader>hs", ":Gitsigns stage_hunk<CR>" },
      { "<leader>hu", ":Gitsigns undo_stage_hunk<CR>" },
      { "<leader>hS", ":Gitsigns stage_buffer<CR>" },
      { "<leader>hd", ":Gitsigns diffthis<CR>" },
      {
        "<leader>hD",
        function()
          require("gitsigns").diffthis("~")
        end,
      },
    },
  },
}
