#!/usr/bin/env bash
# Claude Code status line: dir | model | context usage
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
used_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')

# ANSI colors (dimmed-friendly)
RESET='\033[0m'
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
MAGENTA='\033[35m'
DIM='\033[2m'

# Shorten home directory to ~
# Use a variable for the replacement so bash 5 doesn't tilde-expand a bare ~
# and bash 3.2 doesn't keep a literal backslash from \~.
tilde='~'
if [ -n "$HOME" ]; then
    cwd="${cwd/#$HOME/$tilde}"
fi

parts=()

# Directory segment
if [ -n "$cwd" ]; then
    parts+=("$(printf "${CYAN}%s${RESET}" "$cwd")")
fi

# Model segment
if [ -n "$model" ]; then
    parts+=("$(printf "${MAGENTA}%s${RESET}" "$model")")
fi

# Git segment: branch + dirty marker
if [ -n "$cwd" ] && command -v git >/dev/null 2>&1; then
    branch=$(git -C "${cwd/#~/$HOME}" symbolic-ref --quiet --short HEAD 2>/dev/null \
        || git -C "${cwd/#~/$HOME}" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        if [ -n "$(git -C "${cwd/#~/$HOME}" status --porcelain 2>/dev/null)" ]; then
            dirty='*'
            git_color="$YELLOW"
        else
            dirty=''
            git_color="$GREEN"
        fi
        parts+=("$(printf "${git_color}\xee\x82\xa0 %s%s${RESET}" "$branch" "$dirty")")
    fi
fi

# Context segment: tokens used + percentage, only when available
if [ -n "$used_pct" ] && [ -n "$used_tokens" ]; then
    # Choose color based on usage
    if awk "BEGIN{exit !($used_pct >= 80)}"; then
        ctx_color="$YELLOW"
    else
        ctx_color="$GREEN"
    fi
    tokens_fmt=$(awk -v t="$used_tokens" 'BEGIN{printf "%.1fk", t/1000}')
    pct_fmt=$(printf '%.0f' "$used_pct" 2>/dev/null || echo "$used_pct")
    parts+=("$(printf "${DIM}ctx:${RESET}${ctx_color}%s %s%%${RESET}" "$tokens_fmt" "$pct_fmt")")
fi

# Join with separator
sep="$(printf " ${DIM}|${RESET} ")"
result=""
for part in "${parts[@]}"; do
    if [ -z "$result" ]; then
        result="$part"
    else
        result="$result$sep$part"
    fi
done

printf "%b" "$result"
