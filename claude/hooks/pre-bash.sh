#!/bin/bash
# Claude Code PreToolUse Hook (Bash)
# git push の前に CLAUDE.md が最近更新されているかチェック
# 更新されていなければブロックして更新を促す

CWD="${CLAUDE_PROJECT_DIR:-.}"

# プロジェクトディレクトリとして不適切な場所ではスキップ
case "$CWD" in
  "$HOME"|"$HOME/dev"|"/"|"/tmp"|"/var"|"/etc"|"/usr")
    exit 0
    ;;
esac

# stdin から JSON 入力を読み取り、コマンドを抽出
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null)

# git push コマンドかどうかチェック
if echo "$COMMAND" | grep -qE '^\s*git\s+push'; then

  # CLAUDE.md が存在しない場合はブロック
  if [ ! -f "$CWD/CLAUDE.md" ]; then
    echo "git push する前に CLAUDE.md を作成してください。プロジェクトの概要、ディレクトリ構成、使用技術、開発ルール等を記載してください。作成後に再度 push してください。" >&2
    exit 2
  fi

  # CLAUDE.md の最終更新時刻をチェック（5分以内に更新されていなければブロック）
  if [ "$(uname)" = "Darwin" ]; then
    LAST_MODIFIED=$(stat -f %m "$CWD/CLAUDE.md")
  else
    LAST_MODIFIED=$(stat -c %Y "$CWD/CLAUDE.md")
  fi
  NOW=$(date +%s)
  AGE_SEC=$(( NOW - LAST_MODIFIED ))

  if [ "$AGE_SEC" -gt 300 ]; then
    AGE_MIN=$(( AGE_SEC / 60 ))
    echo "CLAUDE.md が ${AGE_MIN} 分前から更新されていません。git push する前に CLAUDE.md をプロジェクトの最新状態を反映するよう更新してください。更新後に再度 push してください。" >&2
    exit 2
  fi
fi

# それ以外のコマンドは許可
exit 0
