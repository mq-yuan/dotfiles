# pskill: kill processes by name, supports -9 and print-only mode.
pskill() {
  local sig=""
  local print_only=0
  local pattern=""

  # Parse options.
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -9)
        sig="-9"
        shift
        ;;
      -p|--print)
        print_only=1
        shift
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "Unknown option: $1"
        echo "Usage: pskill [-9] [-p|--print] pattern"
        return 1
        ;;
      *)
        break
        ;;
    esac
  done

  if [[ "$#" -lt 1 ]]; then
    echo "Usage: pskill [-9] [-p|--print] pattern"
    return 1
  fi

  # Remaining args as pattern (supports spaces).
  pattern="$*"

  # Find PIDs by pattern.
  local pids
  pids=$(ps aux | grep -- "$pattern" | grep -v grep | awk '{print $2}')

  if [[ -z "$pids" ]]; then
    echo "No matching processes for pattern: '$pattern'"
    return 1
  fi

  echo "Found PIDs for '$pattern': $pids"

  # Print-only mode: do not kill.
  if [[ "$print_only" -eq 1 ]]; then
    echo "Print-only mode; not killing any process."
    return 0
  fi

  # Show each PID then kill.
  for pid in $pids; do
    echo "Killing PID $pid with 'kill $sig'"
    kill $sig "$pid"
  done
}
