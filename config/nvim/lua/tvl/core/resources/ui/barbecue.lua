local Icon = require("tvl.core.icons")

local function get_icons()
  if vim.g.nerd_font_enabled == true then
    return Icon.kinds
  else
    return false
  end
end

local function get_symbols()
  if vim.g.nerd_font_enabled == true then
    return Icon.bbq_symbols
  else
    local symbols = Icon.bbq_symbols
    symbols.separator = '>'
    return symbols
  end
end

return {
  {
    "utilyre/barbecue.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "SmiteshP/nvim-navic",
      {
        "nvim-tree/nvim-web-devicons",
        enabled = vim.g.nerd_font_enabled
      },
    },
    opts = {
      attach_navic = false,
      theme = "auto",
      include_buftypes = { "" },
      exclude_filetypes = { "gitcommit", "Trouble", "toggleterm" },
      show_modified = false,
      symbols = get_symbols(),
      kinds = get_icons(),
    },
  },
}
