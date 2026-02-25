# Claude Code セッション状態管理 (tmux)

tmux + Claude Code hooks で複数セッションの状態を可視化する設定一式。

## アーキテクチャ

```
Claude Code (各 tmux ペイン内)
  │
  ├─ Hook 発火時 → state-update.sh → /tmp/claude-sessions/{N}.state に状態書き込み
  │                                 └→ tmux ペインボーダー色を即時変更
  │
  └─ statusLine → statusline-command.sh → ctx:45% | 5h:23%(2h30m) | 7d:12%

tmux (1秒ごとにステータスバー更新)
  ├─ ステータスバー右: 各ペインの ディレクトリ名:絵文字
  └─ ペインボーダー上部: 絵文字 + 状態テキスト + 経過時間 + パス
```

## 状態と表示

| 状態 | 絵文字 | ボーダー色 | カラーコード |
|------|--------|-----------|------------|
| 思考中 | 🧠 | グリーン | `#a6e3a1` |
| タスク完了 | ✅ | グレー | `#a6adc8` |
| 途中入力待ち | 💬 | オレンジ | `#fab387` |
| 許可待ち | 🛑 | レッド | `#f38ba8` |
| 起動中 | 🚀 | ブルー | `#89b4fa` |
| 未起動 | -- | グレー | `#585b70` |
| 非アクティブ (5分+) | 元の絵文字+💤 | 元の色 | - |

## ファイル構成

```
tmux-settings/
├── .tmux.conf                      # → ~/.tmux.conf
├── settings.json                   # → ~/.claude/settings.json
├── hooks/
│   ├── state-update.sh             # → ~/.claude/hooks/state-update.sh
│   └── state-stop.sh               # → ~/.claude/hooks/state-stop.sh
├── scripts/
│   ├── tmux-pane-status.sh         # → ~/.claude/scripts/tmux-pane-status.sh
│   ├── tmux-window-status.sh       # → ~/.claude/scripts/tmux-window-status.sh
│   └── tmux-pane-colors.sh         # → ~/.claude/scripts/tmux-pane-colors.sh (予備)
└── bin/
    └── claude-sessions.sh          # → ~/bin/claude-sessions.sh
```

## セットアップ

```bash
# 1. tmux インストール
brew install tmux

# 2. ファイルをコピー
cp .tmux.conf ~/.tmux.conf
cp hooks/*.sh ~/.claude/hooks/
cp scripts/*.sh ~/.claude/scripts/
cp bin/claude-sessions.sh ~/bin/
chmod +x ~/.claude/hooks/*.sh ~/.claude/scripts/*.sh ~/bin/claude-sessions.sh

# 3. settings.json の hooks セクションを ~/.claude/settings.json にマージ
```

## 使い方

```bash
# マルチセッション起動
~/bin/claude-sessions.sh          # 4ペイン (デフォルト)
~/bin/claude-sessions.sh 6        # 6ペイン
~/bin/claude-sessions.sh 6 tiled  # 6ペイン tiledレイアウト

# 各ペインで claude を起動
claude

# 設定リロード (tmux 内で)
prefix + r  (Ctrl-b → r)
```

## tmux キーバインド

| キー | 動作 |
|------|------|
| `Ctrl-b \|` | 水平分割 |
| `Ctrl-b -` | 垂直分割 |
| `Alt + 矢印` | ペイン移動 (prefix不要) |
| `Ctrl-b r` | 設定リロード |

## Claude Code Hooks

| イベント | 動作 |
|---------|------|
| `UserPromptSubmit` | → thinking (🧠) |
| `SessionStart` | → starting (🚀) |
| `PermissionRequest` | → permission (🛑) + 音声 + macOS通知 |
| `Stop` | → state-stop.sh で判定: completed (✅) or waiting (💬) + 音声 + macOS通知 |

## ボーダー色の更新タイミング

1. **即時**: Hook 発火 → `state-update.sh` が `tmux set-option -p` で直接変更
2. **フォールバック (1秒ごと)**: `tmux-window-status.sh` がステータスバー更新のついでに再適用
