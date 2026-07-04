# Neovim

設定ファイル: `configs/nvim/`(→ `~/.config/nvim/`)

- プラグインマネージャ: [lazy.nvim](https://github.com/folke/lazy.nvim)(初回起動時に自動インストール)
- カラースキーム: tokyonight(night スタイル、coolnight 風にカスタム)
- **リーダーキー: `Space`**

## 管理コマンド

| コマンド | 動作 |
|---|---|
| `:Lazy` | プラグインの管理画面(インストール / 更新 / 削除) |
| `:Mason` | LSP サーバー・フォーマッタ・リンタの管理画面 |
| `:TSUpdate` | treesitter パーサーの更新 |

## 基本キーマップ(`core/keymaps.lua`)

| キー | モード | 動作 |
|---|---|---|
| `jk` | 挿入 | ノーマルモードに戻る(ESC 相当) |
| `<Space>nh` | ノーマル | 検索ハイライトを消す |
| `<Space>+` / `<Space>-` | ノーマル | カーソル下の数値をインクリメント / デクリメント |

### ウィンドウ / タブ

| キー | 動作 |
|---|---|
| `<Space>sv` / `<Space>sh` | 縦分割 / 横分割 |
| `<Space>se` | 分割サイズを均等化 |
| `<Space>sx` | 現在の分割を閉じる |
| `<Space>sm` | 分割の最大化トグル(vim-maximizer) |
| `Ctrl+h/j/k/l` | ウィンドウ間移動(tmux ペインともシームレス) |
| `<Space>to` / `<Space>tx` | タブを開く / 閉じる |
| `<Space>tn` / `<Space>tp` | 次 / 前のタブ |
| `<Space>tf` | 現在のバッファを新規タブで開く |

タブは bufferline によりエディタ上部にスラント区切りで表示されます。

## ファイル操作

### Telescope(あいまい検索)

| キー | 動作 |
|---|---|
| `<Space>ff` | ファイル検索 |
| `<Space>fr` | 最近開いたファイル |
| `<Space>fs` | 全文検索(live grep) |
| `<Space>fc` | カーソル下の文字列で全文検索 |
| `<Space>ft` | TODO コメント検索 |

検索結果内: `Ctrl+k/j` で上下移動、`Ctrl+q` で選択を quickfix に送って Trouble で開く。

### nvim-tree(ファイルエクスプローラ)

| キー | 動作 |
|---|---|
| `<Space>ee` | ツリーの表示 / 非表示 |
| `<Space>ef` | 現在のファイル位置でツリーを開く |
| `<Space>ec` | ツリーを全部折りたたむ |
| `<Space>er` | ツリーを再読み込み |

## LSP(`plugins/lsp/`)

Mason が LSP サーバーを自動インストールし(`:Mason` で確認)、対応言語: TypeScript / HTML / CSS / Tailwind / Svelte / Lua / GraphQL / Emmet / Prisma / Python / Go / Terraform / Kotlin / Swift(sourcekit) / JSON / YAML / Protobuf / Bash / Docker / Markdown / Rust / C・C++ / TOML / SQL。

バッファに LSP がアタッチされると以下が有効になります:

| キー | 動作 |
|---|---|
| `gd` / `gD` | 定義 / 宣言へジャンプ |
| `gR` | 参照一覧(Telescope) |
| `gi` / `gt` | 実装 / 型定義一覧 |
| `K` | ホバードキュメント表示 |
| `<Space>ca` | コードアクション |
| `<Space>rn` | シンボルのリネーム |
| `<Space>d` / `<Space>D` | 行 / バッファの診断表示 |
| `[d` / `]d` | 前 / 次の診断へジャンプ(フロート表示付き) |
| `<Space>rs` | LSP 再起動 |

### 補完(nvim-cmp)

挿入モードで自動表示。LSP / スニペット(LuaSnip + friendly-snippets)/ バッファ / パスが補完ソース。

| キー | 動作 |
|---|---|
| `Ctrl+j` / `Ctrl+k` | 候補の選択(下 / 上) |
| `Enter` | 確定 |
| `Ctrl+Space` | 補完を手動で表示 |
| `Ctrl+e` | 補完ウィンドウを閉じる |
| `Ctrl+f` / `Ctrl+b` | ドキュメントのスクロール |

### フォーマット / リント

- **conform.nvim**: `<Space>mp` でファイル(ビジュアルモードでは範囲)をフォーマット。prettier / stylua / isort / black など
- **nvim-lint**: 保存時に自動リント。`<Space>l` で手動実行。eslint_d / pylint など

> 注意: `<Space>mp` は markview(Markdown プレビュー)のトグルにも割り当てられており、**キーが重複しています**。Markdown ファイルでの挙動は後から読み込まれた方が優先されます。

## Git 連携

### gitsigns(ハンク操作)

| キー | 動作 |
|---|---|
| `]h` / `[h` | 次 / 前の変更ハンクへ |
| `<Space>hs` / `<Space>hr` | ハンクをステージ / リセット(ビジュアルモード対応) |
| `<Space>hS` / `<Space>hR` | バッファ全体をステージ / リセット |
| `<Space>hu` | ステージの取り消し |
| `<Space>hp` | ハンクのプレビュー |
| `<Space>hb` | 行の blame 表示 |
| `<Space>hB` | 行 blame の常時表示トグル |
| `<Space>hd` | diff 表示 |

### lazygit

`<Space>lg` で lazygit を開く(要 `brew "lazygit"`)。

## 編集系プラグイン

| プラグイン | 使い方 |
|---|---|
| Comment.nvim | `gcc` で行コメント、`gc` + モーション(例: `gc3j`)、ビジュアル選択で `gc`。JSX/TSX 対応 |
| nvim-surround | `ys<motion><char>` で囲む(例: `ysiw"`)、`ds<char>` で削除、`cs<old><new>` で変更 |
| substitute.nvim | `s<motion>` でレジスタ内容と置き換え(例: `siw`)、`ss` で行、`S` で行末まで |
| nvim-autopairs | 括弧・クォートの自動補完(treesitter 連携) |
| nvim-ts-autotag | HTML/JSX タグの自動クローズ・リネーム |
| todo-comments | `TODO:` `FIX:` 等をハイライト。`]t` / `[t` で移動、`<Space>ft` で一覧 |
| indent-blankline | インデントガイド表示 |
| markview | Markdown のインラインプレビュー。`<Space>ms` で分割プレビュー |

## 診断一覧(Trouble)

| キー | 動作 |
|---|---|
| `<Space>xw` | ワークスペース全体の診断一覧 |
| `<Space>xd` | 現在バッファの診断一覧 |
| `<Space>xq` | quickfix リスト |
| `<Space>xl` | location リスト |
| `<Space>xt` | TODO 一覧 |

## セッション管理(auto-session)

| キー | 動作 |
|---|---|
| `<Space>wr` | カレントディレクトリのセッションを復元 |
| `<Space>ws` | セッションを保存 |

`~/` `~/Downloads` などトップレベルディレクトリでは自動復元されません。

## その他

- **alpha**: 引数なしで `nvim` を起動するとダッシュボードを表示
- **which-key**: `<Space>` を押して 500ms 待つと、続けて押せるキーの一覧がポップアップ表示される(キーマップを忘れたときに便利)
- **lualine**: ステータスライン(lazy.nvim の更新通知も表示)
- クリップボードはシステムと共有(`unnamedplus`)
