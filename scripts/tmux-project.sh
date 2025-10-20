#!/bin/sh
set -eu

TMUX_BIN="$(command -v tmux || { echo 'tmux not found'; exit 1; })"
FZF_BIN="$(command -v fzf || { echo 'fzf not found'; exit 1; })"
ZOXIDE_BIN="$(command -v zoxide || { echo 'zoxide not found'; exit 1; })"

sessions="$("$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null || true)"

choice="$(
  { echo "Create new session…"; printf '%s\n' "$sessions"; } \
  | "$FZF_BIN" --prompt="Sessions: " --height=40% --reverse --border
)"

[ -n "$choice" ] || exit 0

if [ "$choice" = "Create new session…" ]; then
    printf "New session name: "
    read -r new_name
    [ -n "$new_name" ] || exit 0
    session="$new_name"
    create=1
    dir="$("$ZOXIDE_BIN" query -l | "$FZF_BIN" --prompt="Choose directory: " --height=40% --reverse --border)"
    [ -n "$dir" ] || exit 0
else
    session="$choice"
    create=0
fi

if [ -n "${TMUX-}" ]; then
    # Inside tmux
    if [ "$create" -eq 1 ] && ! "$TMUX_BIN" has-session -t "$session" 2>/dev/null; then
        "$TMUX_BIN" new-session -ds "$session" -c "$dir"
    fi
    exec "$TMUX_BIN" switch-client -t "$session"
else
# Outside tmux
if [ "$create" -eq 1 ]; then
    exec "$TMUX_BIN" new-session -s "$session" -c "$dir"
else
    exec "$TMUX_BIN" attach -t "$session"
fi
fi
