# GPU idle monitor autostart (interactive shells only).
if [[ $- == *i* ]]; then
  GPU_MONITOR_DIR="$HOME/Tools/gpu_monitor"
  MONITOR_LOG="$HOME/logs/gpu_idle_monitor.log"
  mkdir -p "$HOME/logs" "$HOME/.cache"

  # Do not start another monitor if one is already running.
  if pgrep -u "$USER" -f "$GPU_MONITOR_DIR/monitor_gpu_idle.sh" >/dev/null 2>&1; then
    :
  else
    MONITOR_CMD="$GPU_MONITOR_DIR/monitor_gpu_idle.sh -c \"$GPU_MONITOR_DIR/launch_raytracer_test.sh\" -t 15 -d 10800 -i 60 -m all"
    nohup bash -lc "$MONITOR_CMD" >>"$MONITOR_LOG" 2>&1 &
  fi
fi
