# Claude Code セッション状態管理 (tmux設定)

## プロジェクト概要
tmux + Claude Code hooks を組み合わせて、複数の Claude Code セッションの状態（思考中・入力待ち・許可待ち等）をリアルタイムに可視化するための設定一式。

## ディレクトリ構成
```
tmux-settings/
├── .tmux.conf                      # tmux本体設定 → ~/.tmux.conf
├── settings.json                   # Claude Code設定 → ~/.claude/settings.json
├── hooks/
│   ├── state-update.sh             # 状態更新フック → ~/.claude/hooks/state-update.sh
│   └── state-stop.sh               # Stop時の状態判定 → ~/.claude/hooks/state-stop.sh
├── scripts/
│   ├── tmux-pane-status.sh         # ペインボーダー状態表示
│   ├── tmux-window-status.sh       # ステータスバー右側表示 + ボーダー色フォールバック
│   └── tmux-pane-colors.sh         # ボーダー色更新（予備）
└── bin/
    └── claude-sessions.sh          # マルチセッション起動スクリプト → ~/bin/
```

## 使用技術
- **tmux**: ターミナルマルチプレクサ
- **Bash**: フック・スクリプト全般
- **Claude Code Hooks**: セッション状態のトリガー（UserPromptSubmit, SessionStart, PermissionRequest, Stop）
- **macOS固有**: `afplay`（通知音）、`osascript`（デスクトップ通知）

## 状態管理の仕組み
- 状態ファイル: `/tmp/claude-sessions/{pane_id}.state`（JSON形式）
- Hook発火 → `state-update.sh` が状態書き込み + ペインボーダー色を即時変更
- `tmux-window-status.sh` が1秒ごとにステータスバー更新 + ボーダー色フォールバック

## 重要なコマンド
```bash
# マルチセッション起動
~/bin/claude-sessions.sh          # 4ペイン（デフォルト）
~/bin/claude-sessions.sh 6 tiled  # 6ペイン tiledレイアウト

# tmux設定リロード（tmux内で）
prefix + r  (Ctrl-b → r)

# ファイルのデプロイ（手動コピー）
cp .tmux.conf ~/.tmux.conf
cp hooks/*.sh ~/.claude/hooks/
cp scripts/*.sh ~/.claude/scripts/
cp bin/*.sh ~/bin/
chmod +x ~/.claude/hooks/*.sh ~/.claude/scripts/*.sh ~/bin/*.sh
```

## 環境構築手順
1. `brew install tmux`
2. 上記デプロイコマンドでファイルをコピー
3. `settings.json` の hooks セクションを `~/.claude/settings.json` にマージ

## 開発ルール
- シェルスクリプトは `#!/bin/bash` を使用
- 状態ファイルはJSON形式で統一
- カラーコードは Catppuccin Mocha パレットに準拠

## Git ルール
- コミットメッセージは日本語で書くこと
