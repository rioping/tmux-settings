#!/bin/bash
# Stop hook: タスク完了 vs 途中入力待ちを判定
# stdin から Stop hook の JSON を読み取り、last_assistant_message を分析
INPUT=$(cat)
LAST_MSG=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')

# 質問判定: 最後のメッセージが「？」「?」で終わるかチェック
# （末尾の空白・改行を除去してから判定）
TRIMMED=$(echo "$LAST_MSG" | sed 's/[[:space:]]*$//')
if echo "$TRIMMED" | grep -q '[？?]$'; then
  STATE="waiting"
else
  STATE="completed"
fi

bash ~/.claude/hooks/state-update.sh "$STATE"
