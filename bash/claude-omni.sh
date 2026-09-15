#!/usr/bin/env bash

# [commit.generation]
# command = "omniroute launch -p 2>/dev/null | grep -vE '📋|⚠|\\(node:|\\[claude-code:|Use `node'"

set -u
export LC_ALL=C.UTF-8

COMMIT_REGEX='^(feat|fix|refactor|docs|test|chore|build|ci|perf)(\([a-z0-9._/-]+\))?: .+'

# Tunables
MAX_DIFF_LINES=300
MAX_LINES_PER_FILE=80
AI_TIMEOUT=15
MAX_LEN=72
HISTORY_SAMPLE=15

# --------------------------------------------------
# 1. Verify Git repository
# --------------------------------------------------

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 1
fi

# --------------------------------------------------
# 2. Verify staged changes
# --------------------------------------------------

if git diff --cached --quiet; then
  exit 1
fi

# --------------------------------------------------
# 3. Gather staged diff + stat summary (rename-aware)
# --------------------------------------------------

STAT="$(git diff --cached -M --stat)"
FILES="$(git diff --cached -M --name-only)"

if [[ -z "$STAT" ]]; then
  exit 1
fi

# Files whose *content* is noisy/generated - list them, don't dump their diff
NOISY_PATTERN='(^|/)(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lock|Cargo\.lock|composer\.lock|Gemfile\.lock)$|(^|/)(dist|build|out|node_modules|coverage|vendor)/|\.min\.(js|css)$|\.(map|lock)$'

CONTENT_FILES=()
NOISY_FILES=()
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  if grep -qE "$NOISY_PATTERN" <<<"$f"; then
    NOISY_FILES+=("$f")
  else
    CONTENT_FILES+=("$f")
  fi
done <<<"$FILES"

# --------------------------------------------------
# 4. Build diff body with per-file caps (not a blind head -n)
#    A single huge file shouldn't crowd out every other file when
#    the overall diff gets truncated.
# --------------------------------------------------

DIFF=""
TRUNCATED=0
if [[ ${#CONTENT_FILES[@]} -gt 0 ]]; then
  for f in "${CONTENT_FILES[@]}"; do
    FILE_DIFF="$(git diff --cached -M --function-context -- "$f")"
    FILE_LINES=$(wc -l <<<"$FILE_DIFF")
    if ((FILE_LINES > MAX_LINES_PER_FILE)); then
      FILE_DIFF="$(head -n "$MAX_LINES_PER_FILE" <<<"$FILE_DIFF")"
      FILE_DIFF="${FILE_DIFF}"$'\n'"... (truncated, ${FILE_LINES} lines total in this file)"
      TRUNCATED=1
    fi
    DIFF="${DIFF}${FILE_DIFF}"$'\n'
  done
else
  DIFF="$(git diff --cached -M)"
fi

TOTAL_LINES=$(wc -l <<<"$DIFF")
if ((TOTAL_LINES > MAX_DIFF_LINES)); then
  DIFF="$(head -n "$MAX_DIFF_LINES" <<<"$DIFF")"
  TRUNCATED=1
fi

NOISY_NOTE=""
if [[ ${#NOISY_FILES[@]} -gt 0 ]]; then
  NOISY_NOTE=$'\n'"Additionally, these generated/dependency files changed (content omitted): $(printf '%s, ' "${NOISY_FILES[@]}")"
fi

TRUNCATE_NOTE=""
if ((TRUNCATED == 1)); then
  TRUNCATE_NOTE=$'\n'"NOTE: Some diff content below was truncated for length."
fi

# --------------------------------------------------
# 5. Learn the repo's actual commit style from recent history
#    (few-shot examples, and a signal for scope conventions)
# --------------------------------------------------

RECENT_LOG="$(git log -n "$HISTORY_SAMPLE" --pretty=format:'%s' 2>/dev/null || true)"

HISTORY_BLOCK=""
if [[ -n "$RECENT_LOG" ]]; then
  HISTORY_BLOCK=$'\n'"Recent commit messages in this repo, for style/tone/scope-naming reference only \
(match how scopes are named here if a scope applies; do not copy their content):"$'\n'"$RECENT_LOG"
fi

# --------------------------------------------------
# 6. Branch name as a scope/intent hint (e.g. feature/auth-login,
#    fix/1234-null-check) — mirrors how editor tooling uses branch
#    context as a weak signal.
# --------------------------------------------------

BRANCH="$(git symbolic-ref --short -q HEAD || echo "")"
BRANCH_NOTE=""
if [[ -n "$BRANCH" && "$BRANCH" != "main" && "$BRANCH" != "master" ]]; then
  BRANCH_NOTE=$'\n'"Current branch name (weak hint only, ignore if unrelated to the diff): $BRANCH"
fi

# --------------------------------------------------
# 7. Ask AI
# --------------------------------------------------

PROMPT=$(
  cat <<EOF
Generate exactly ONE Conventional Commit message for the staged Git changes below.

Rules:

- Output ONLY the commit message.
- Exactly one line.
- Maximum ${MAX_LEN} characters.
- Format:
  type(scope): description

Scope is optional.

Allowed types:

feat
- New user-facing functionality or capability.

fix
- Fixes broken or incorrect existing behavior.

refactor
- Internal restructuring without changing behavior.

perf
- Performance improvement.

docs
- Documentation-only changes.

test
- Test-only changes.

ci
- CI/CD workflows or automation.

build
- Build system or dependency/build tooling.

chore
- Repository configuration, developer tooling, maintenance,
  generated files, or other non-feature work.

Choose the most specific and accurate type.

Do NOT use feat merely because files are being added.

Use a scope only when the affected component/module can be
identified confidently. Otherwise omit the scope.

Use imperative mood, lowercase the description, no trailing period.

Do not include:
- Markdown
- code fences
- quotes
- bullets
- numbering
- explanations
- multiple alternatives
- blank lines
$HISTORY_BLOCK
$BRANCH_NOTE

CHANGE SUMMARY (git diff --stat, renames detected):

$STAT
$NOISY_NOTE
$TRUNCATE_NOTE

STAGED DIFF (non-generated files, function context included, per-file capped):

$DIFF
EOF
)

run_ai() {
  timeout "$AI_TIMEOUT" omniroute launch -p "$PROMPT" 2>/dev/null |
    sed 's/^[[:space:]]*//' |
    sed 's/^[`"]*//' |
    sed 's/[`"]*[[:space:]]*$//' |
    sed 's/\.$//' |
    grep -E "$COMMIT_REGEX" |
    head -n 1
}

MESSAGE=""
for attempt in 1 2; do
  MESSAGE="$(run_ai)"
  if [[ -n "$MESSAGE" ]] && ((${#MESSAGE} <= MAX_LEN)); then
    break
  fi
  MESSAGE=""
done

# --------------------------------------------------
# 8. Validate AI result
# --------------------------------------------------

if [[ -n "$MESSAGE" ]]; then
  printf '%s\n' "$MESSAGE"
  exit 0
fi

# --------------------------------------------------
# 9. Deterministic fallback (ordered most-specific first)
# --------------------------------------------------

if grep -qE '(^|/)\.github/workflows/|(^|/)\.gitlab-ci' <<<"$FILES"; then
  FALLBACK="ci: update automation configuration"
elif grep -qE '(^|/)(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lock|Cargo\.lock|composer\.lock|Gemfile\.lock)$' <<<"$FILES"; then
  FALLBACK="build: update project dependencies"
elif grep -qE '(^|/)package\.json$' <<<"$FILES"; then
  FALLBACK="build: update project dependencies"
elif grep -qE '(^|/)(README|CHANGELOG)(\.|$)' <<<"$FILES"; then
  FALLBACK="docs: update project documentation"
elif grep -qE '(^|/)(test|tests|__tests__)(/|$)' <<<"$FILES"; then
  FALLBACK="test: update test files"
elif grep -qE '(^|/)(\.config|\.worktreeinclude|\.editorconfig)$|\.(toml|yaml|yml)$' <<<"$FILES"; then
  FALLBACK="chore: update project configuration"
else
  FALLBACK="chore: update repository files"
fi

printf '%s\n' "$FALLBACK"
