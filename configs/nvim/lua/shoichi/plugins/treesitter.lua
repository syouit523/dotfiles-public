return {
  "nvim-treesitter/nvim-treesitter",
  -- master ブランチは frozen かつ Neovim 0.12 非サポート (README)。
  -- 0.12 でクエリマッチ API が変わり master のインジェクション用ディレクティブが
  -- クラッシュするため、0.12+ 専用の main ブランチへ移行する。
  branch = "main",
  -- main ブランチは lazy-loading 非対応 (README) のため常時ロードする。
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local treesitter = require("nvim-treesitter")

    treesitter.setup()

    -- インストールするパーサー
    local ensure_installed = {
      "json",
      "javascript",
      "typescript",
      "tsx",
      "yaml",
      "html",
      "css",
      "prisma",
      "markdown",
      "markdown_inline",
      "svelte",
      "graphql",
      "bash",
      "lua",
      "vim",
      "dockerfile",
      "gitignore",
      "query",
      "vimdoc",
      "c",
    }

    -- 未インストールのパーサーのみ install する (install は非同期)。
    local ok_installed, installed = pcall(treesitter.get_installed)
    local to_install = ensure_installed
    if ok_installed then
      to_install = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure_installed)
    end
    if #to_install > 0 then
      treesitter.install(to_install)
    end

    -- main ブランチはハイライト/インデントを自動で有効化しないため、
    -- FileType ごとにパーサーが利用可能なら treesitter を起動する。
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    -- nvim-ts-autotag は treesitter モジュール統合 (autotag = { enable = true })
    -- が廃止されたため、独立して setup する必要がある
    require("nvim-ts-autotag").setup({})
  end,
}
