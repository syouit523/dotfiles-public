local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- vim.loop は 0.10 で deprecated (vim.uv に改名)
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "shoichi.plugins" }, { import = "shoichi.plugins.lsp"} }, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
