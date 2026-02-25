#!/bin/bash
# 各ペインの状態に応じてボーダー色を動的に変更
STATE_DIR="/tmp/claude-sessions"

for pane_id in $(tmux list-panes -a -F '#{pane_id}'); do
  # pane_id は %0, %1, ... の形式。% を除去してファイル名にする
  id="${pane_id//\%/}"
  STATE_FILE="${STATE_DIR}/${id}.state"

  if [ ! -f "$STATE_FILE" ]; then
    tmux set-option -t "$pane_id" -p pane-border-style "fg=#585b70" 2>/dev/null
    continue
  fi

  state=$(grep -o '"state":"[^"]*"' "$STATE_FILE" | cut -d'"' -f4)

  case "$state" in
    thinking)   color="#a6e3a1" ;;  # グリーン: 思考中
    idle)       color="#fab387" ;;  # オレンジ: 入力待ち
    permission) color="#f38ba8" ;;  # レッド: 許可待ち
    starting)   color="#89b4fa" ;;  # ブルー: 起動中
    *)          color="#585b70" ;;  # グレー: 不明
  esac

  tmux set-option -t "$pane_id" -p pane-border-style "fg=${color}" 2>/dev/null
done
