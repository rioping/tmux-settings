#!/bin/bash
# Claude Code State Tracker
# 引数: $1 = 状態名 (thinking, completed, waiting, permission, starting)
STATE="$1"
STATE_DIR="/tmp/claude-sessions"
mkdir -p "$STATE_DIR"

# tmux pane ID をキーとして使用（TMUX_PANE は %0, %1 等）
PANE_ID="${TMUX_PANE:-unknown}"
STATE_FILE="${STATE_DIR}/${PANE_ID//\%/}.state"

# JSON形式で状態を書き込む
cat > "$STATE_FILE" << EOF
{"state":"${STATE}","timestamp":$(date +%s),"pane":"${PANE_ID}"}
EOF

# tmux 内であればペインボーダー色を即時更新
if [ -n "$TMUX_PANE" ]; then
  case "$STATE" in
    thinking)   color="#a6e3a1" ;;  # グリーン
    completed)  color="#a6adc8" ;;  # グレー（タスク完了）
    waiting)    color="#fab387" ;;  # オレンジ（途中入力待ち）
    permission) color="#f38ba8" ;;  # レッド
    starting)   color="#89b4fa" ;;  # ブルー
    *)          color="#585b70" ;;  # グレー
  esac
  tmux set-option -t "$TMUX_PANE" -p pane-border-style "fg=${color}" 2>/dev/null
  tmux set-option -t "$TMUX_PANE" -p pane-active-border-style "fg=${color}" 2>/dev/null
fi
