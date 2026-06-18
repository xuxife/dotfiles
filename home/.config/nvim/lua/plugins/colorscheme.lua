return {
  -- Install monokai-nightasty
  {
    "polirritmico/monokai-nightasty.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      hl_styles = {
        comments = { italic = true },
        keywords = { italic = false },
      },
      color_overrides = {
        light = {
          background = "#f8efe7",
        },
      },
      on_highlights = function(hl, c)
        hl.Normal = { bg = "#f8efe7", fg = hl.Normal and hl.Normal.fg }
        hl.NormalNC = { bg = "#f8efe7" }
        hl.NormalFloat = { bg = "#f8efe7" }
        hl.SignColumn = { bg = "#f8efe7" }
        hl.EndOfBuffer = { bg = "#f8efe7" }
      end,
    },
  },

  -- Tell LazyVim to use it
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "monokai-nightasty",
    },
  },
}
