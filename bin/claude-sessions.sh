#!/bin/bash
# Claude Code マルチセッション起動スクリプト
# 使い方: claude-sessions.sh [セッション数] [レイアウト]
# 例: claude-sessions.sh 6 tiled
# レイアウト: tiled, even-horizontal, even-vertical

COUNT=${1:-4}
LAYOUT=${2:-tiled}
SESSION="claude"

# 状態ファイルをクリーンアップ
rm -rf /tmp/claude-sessions
mkdir -p /tmp/claude-sessions

# 既存セッションがあればアタッチ
if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach-session -t "$SESSION"
  exit 0
fi

# 新規セッション作成（最初のペイン）
tmux new-session -d -s "$SESSION" -n "claude"

# 残りのペインを作成
for i in $(seq 2 "$COUNT"); do
  tmux split-window -t "$SESSION:1"
  tmux select-layout -t "$SESSION:1" "$LAYOUT"
done

# 最終レイアウト調整
tmux select-layout -t "$SESSION:1" "$LAYOUT"
tmux select-pane -t "$SESSION:1.1"

# アタッチ
tmux attach-session -t "$SESSION"
