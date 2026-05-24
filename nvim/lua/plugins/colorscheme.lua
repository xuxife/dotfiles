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
