return {
  "OXY2DEV/markview.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("markview").setup({
      preview = {
        modes = { "n", "no", "c" },
        hybrid_modes = { "n" },
      },
    })

    vim.keymap.set("n", "<leader>mp", "<cmd>Markview Toggle<CR>", { desc = "Toggle markview" })
    vim.keymap.set("n", "<leader>ms", "<cmd>Markview splitToggle<CR>", { desc = "Toggle markview split" })
  end,
}
