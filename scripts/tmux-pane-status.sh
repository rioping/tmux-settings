#!/bin/bash
# tmux pane-border-format から呼ばれ、該当ペインの状態を表示
# 引数: $1 = pane_id (例: "%0", "%1", ... tmux形式)
RAW_ID="$1"
PANE_ID="${RAW_ID//\%/}"
STATE_FILE="/tmp/claude-sessions/${PANE_ID}.state"

if [ ! -f "$STATE_FILE" ]; then
  echo "---"
  exit 0
fi

STATE=$(grep -o '"state":"[^"]*"' "$STATE_FILE" | cut -d'"' -f4)
TIMESTAMP=$(grep -o '"timestamp":[0-9]*' "$STATE_FILE" | cut -d: -f2)
NOW=$(date +%s)
ELAPSED=$((NOW - TIMESTAMP))

# 経過時間の表示
if [ "$ELAPSED" -lt 60 ]; then
  TIME="${ELAPSED}s"
elif [ "$ELAPSED" -lt 3600 ]; then
  TIME="$((ELAPSED / 60))m"
else
  TIME="$((ELAPSED / 3600))h$((ELAPSED % 3600 / 60))m"
fi

case "$STATE" in
  thinking)   echo "🧠 思考中 (${TIME})" ;;
  idle)       echo "📝 入力待ち (${TIME})" ;;
  permission) echo "🛑 許可待ち (${TIME})" ;;
  starting)   echo "🚀 起動中" ;;
  *)          echo "❓ 不明" ;;
esac
