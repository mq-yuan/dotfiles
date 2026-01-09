# Custom tmux completion for attach sessions.
if command -v tmux >/dev/null 2>&1; then
  _tmux_list_sessions() {
    tmux list-sessions -F '#S' 2>/dev/null
  }

  _tmux_attach_complete() {
    local cur prev cmd subcmd
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmd="${COMP_WORDS[0]}"
    subcmd="${COMP_WORDS[1]}"

    if [[ "$cmd" == "ta" ]]; then
      if [[ "$cur" != -* ]]; then
        COMPREPLY=( $(compgen -W "$(_tmux_list_sessions)" -- "$cur") )
      fi
      return 0
    fi

    if [[ "$prev" == "-t" ]]; then
      case "$subcmd" in
        a|attach|attach-session)
          COMPREPLY=( $(compgen -W "$(_tmux_list_sessions)" -- "$cur") )
          return 0
          ;;
      esac
    fi
  }

  if ! complete -p tmux >/dev/null 2>&1; then
    complete -F _tmux_attach_complete tmux
  fi

  if ! complete -p ta >/dev/null 2>&1; then
    complete -F _tmux_attach_complete ta
  fi
fi
