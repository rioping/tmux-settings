#!/bin/bash
# ステータスバー右側に各ペインのディレクトリ名+ステータスを表示
# 同時にペインボーダー色も更新する（3秒ごとのフォールバック）
STATE_DIR="/tmp/claude-sessions"
STALE_THRESHOLD=300

output=""

for pane_info in $(tmux list-panes -a -F '#{pane_id}:#{pane_current_path}' 2>/dev/null); do
  pane_id="${pane_info%%:*}"
  pane_path="${pane_info#*:}"
  dir_name=$(basename "$pane_path")

  # state ファイルを読む
  id="${pane_id//\%/}"
  STATE_FILE="${STATE_DIR}/${id}.state"

  emoji="❓"
  color="#585b70"

  if [ -f "$STATE_FILE" ]; then
    ts=$(grep -o '"timestamp":[0-9]*' "$STATE_FILE" | cut -d: -f2)
    age=$(($(date +%s) - ts))
    state=$(grep -o '"state":"[^"]*"' "$STATE_FILE" | cut -d'"' -f4)

    case "$state" in
      thinking)   emoji="🧠"; color="#a6e3a1" ;;
      completed)  emoji="✅"; color="#a6adc8" ;;
      waiting)    emoji="💬"; color="#fab387" ;;
      permission) emoji="🛑"; color="#f38ba8" ;;
      starting)   emoji="🚀"; color="#89b4fa" ;;
    esac

    # 5分以上更新なしなら元の状態に💤を付加
    if [ "$age" -gt "$STALE_THRESHOLD" ]; then
      emoji="${emoji}💤"
    fi
  else
    emoji="--"
  fi

  # ペインボーダー色も更新（フォールバック：border + active-border 両方）
  tmux set-option -t "$pane_id" -p pane-border-style "fg=${color}" 2>/dev/null
  tmux set-option -t "$pane_id" -p pane-active-border-style "fg=${color}" 2>/dev/null

  # 区切り
  [ -n "$output" ] && output="${output} | "
  output="${output}${dir_name}:${emoji}"
done

printf "%s" "$output"
