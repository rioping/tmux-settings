#!/bin/bash
# Claude Code SessionStart Hook
# - CLAUDE.md が無ければ作成を指示
# - CLAUDE.md が古ければ更新を推奨
# - git 未管理なら git init + GitHub プライベートリポジトリ作成を指示

CWD="${CLAUDE_PROJECT_DIR:-.}"

# プロジェクトディレクトリとして不適切な場所ではスキップ
case "$CWD" in
  "$HOME"|"$HOME/dev"|"/"|"/tmp"|"/var"|"/etc"|"/usr")
    exit 0
    ;;
esac

HAS_ISSUE=""

# ── CLAUDE.md チェック ──
if [ ! -f "$CWD/CLAUDE.md" ]; then
  HAS_ISSUE=true
  cat <<'INSTRUCTION'
[AUTO-SETUP: CLAUDE.md 作成が必要]
このディレクトリに CLAUDE.md が存在しません。
以下の内容を含む CLAUDE.md を作成してください：
- プロジェクトの概要・目的
- ディレクトリ構成
- 使用技術・ライブラリ・フレームワーク
- 開発ルール・コーディング規約
- 重要なコマンド（ビルド、テスト、デプロイなど）
- 環境構築手順
- その他プロジェクト固有の注意事項

また、以下のルールを必ず CLAUDE.md に含めてください：
## Git ルール
- コミットメッセージは日本語で書くこと
INSTRUCTION
else
  # CLAUDE.md の鮮度チェック（24時間以上経過していたら更新推奨）
  if [ "$(uname)" = "Darwin" ]; then
    LAST_MODIFIED=$(stat -f %m "$CWD/CLAUDE.md")
  else
    LAST_MODIFIED=$(stat -c %Y "$CWD/CLAUDE.md")
  fi
  NOW=$(date +%s)
  AGE_HOURS=$(( (NOW - LAST_MODIFIED) / 3600 ))

  if [ "$AGE_HOURS" -gt 24 ]; then
    HAS_ISSUE=true
    echo "[CLAUDE.md 更新推奨]"
    echo "CLAUDE.md が ${AGE_HOURS} 時間前から更新されていません。"
    echo "プロジェクトの現在の状態を反映するよう CLAUDE.md を更新してください。"
  fi
fi

# ── Git チェック ──
if [ ! -d "$CWD/.git" ]; then
  HAS_ISSUE=true
  DIRNAME=$(basename "$CWD")
  cat <<INSTRUCTION
[AUTO-SETUP: Git 初期化が必要]
このディレクトリは git 管理されていません。
以下を実行してください：
1. git init
2. プロジェクトに適した .gitignore を作成
3. CLAUDE.md が最新であることを確認
4. GitHub にプライベートリポジトリを作成してプッシュ:
   gh repo create "${DIRNAME}" --private --source=. --push
INSTRUCTION
else
  # リモートの存在チェック
  REMOTE=$(cd "$CWD" && git remote -v 2>/dev/null)
  if [ -z "$REMOTE" ]; then
    HAS_ISSUE=true
    DIRNAME=$(basename "$CWD")
    cat <<INSTRUCTION
[AUTO-SETUP: GitHub リモート設定が必要]
git リポジトリにリモートが設定されていません。
GitHub にプライベートリポジトリを作成してください：
  gh repo create "${DIRNAME}" --private --source=. --push
INSTRUCTION
  fi
fi

if [ -z "$HAS_ISSUE" ]; then
  echo "[Project Setup: OK] CLAUDE.md と git は正しく設定されています。"
fi
