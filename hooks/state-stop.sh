#!/bin/bash
# Stop hook: タスク完了 vs 途中入力待ちを判定
# stdin から Stop hook の JSON を読み取り、last_assistant_message を分析
INPUT=$(cat)
LAST_MSG=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')

# 質問判定: 最後の行が「？」「?」で終わるかチェック
# （空行を除去してから最終行だけを判定。grep は全行検索するため tail -1 で絞る）
LAST_LINE=$(echo "$LAST_MSG" | sed '/^[[:space:]]*$/d' | tail -1 | sed 's/[[:space:]]*$//')
if echo "$LAST_LINE" | grep -q '[？?]$'; then
  STATE="waiting"
else
  STATE="completed"
fi

bash ~/.claude/hooks/state-update.sh "$STATE"
