#!/usr/bin/env bash

set -euo pipefail

# gitgui passes the staged diff to the configured AI command via stdin.
DIFF="$(cat)"

if [[ -z "$DIFF" ]]; then
  exit 1
fi

PROMPT=$(
  cat <<EOF
Generate ONE Conventional Commit message for the following staged Git diff.

Rules:
- Output ONLY one commit message.
- Format: type(scope): description
- Use feat, fix, refactor, docs, test, chore, build, ci, or perf.
- Use imperative mood.
- Be concise and specific.
- Maximum 72 characters.
- No explanation.
- No Markdown.
- No bullet points.
- No blank lines.

STAGED DIFF:

$DIFF
EOF
)

ollama run tavernari/git-commit-message:sp_commit_mini "$PROMPT" |
  sed '/^[[:space:]]*$/q' |
  head -n 1
