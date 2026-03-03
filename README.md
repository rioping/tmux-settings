# dotfiles

Mac のカスタム設定を一元管理するリポジトリ。

## セットアップ

```bash
# 1. クローン
git clone git@github.com:rioping/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles

# 2. プレビュー（何が変わるか確認）
./install.sh --dry-run

# 3. インストール（既存ファイルは .bak にバックアップ後、上書き）
./install.sh

# 4. Claude Code にログイン
claude login
```

## 含まれるもの

| カテゴリ | 内容 |
|---------|------|
| **Shell** | `.zshrc`, `.zprofile`（Homebrew, gcloud, aliases, 履歴設定） |
| **Git** | `.gitconfig`, global ignore |
| **Claude Code** | settings.json, hooks（状態管理 + CLAUDE.md 強制）, statusline（使用率表示）|
| **tmux** | Catppuccin Mocha テーマ + Claude セッション状態の可視化 |
| **GitHub CLI** | `gh` の設定 |
| **Docker** | credential helper 設定 |
| **Homebrew** | `Brewfile`（CLI ツール + cask） |
| **macOS** | セットアップ手順, キーボード・トラックパッド設定 |
| **LaunchAgents** | 定期実行タスク |

## マルチセッション起動

```bash
~/bin/claude-sessions.sh          # 4ペイン（デフォルト）
~/bin/claude-sessions.sh 6 tiled  # 6ペイン tiled レイアウト
```
