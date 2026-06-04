#!/bin/bash

SYNC_SCRIPT="$HOME/.config/shell_tool/symlink_note_update.sh"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/watchnote.pid"
LOG_FILE="$HOME/.config/shell_tool/watchnote.log"

# YOUR MASTER LIST - Update this only!
WATCH_LIST=(
  "$HOME/TLXwork/SFTP"
  "$HOME/TLXwork/Project_active"
  "$HOME/TLXwork/Project_finished"
)

usage() {
  echo "Usage: $(basename "$0") {start|stop|restart|status|run}"
}

is_running() {
  [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

run_watcher() {
  echo "Watching: ${WATCH_LIST[*]}"

  bash "$SYNC_SCRIPT" "${WATCH_LIST[@]}"

  fswatch -o -r -l 5 \
    --event Created --event Removed --event Renamed \
    "${WATCH_LIST[@]}" | while read -r _event_count; do

    # We pass the same list directly to the sync script here
    bash "$SYNC_SCRIPT" "${WATCH_LIST[@]}"

  done
}

case "${1:-start}" in
start)
  if is_running; then
    echo "watchnote is already running with PID $(cat "$PID_FILE")"
    exit 0
  fi

  nohup "$0" run >>"$LOG_FILE" 2>&1 &
  echo $! >"$PID_FILE"
  echo "watchnote started with PID $(cat "$PID_FILE")"
  echo "Log: $LOG_FILE"
  ;;
stop)
  if ! is_running; then
    rm -f "$PID_FILE"
    echo "watchnote is not running"
    exit 0
  fi

  pid=$(cat "$PID_FILE")
  pkill -TERM -P "$pid" 2>/dev/null
  kill "$pid"
  rm -f "$PID_FILE"
  echo "watchnote stopped"
  ;;
restart)
  "$0" stop
  "$0" start
  ;;
status)
  if is_running; then
    echo "watchnote is running with PID $(cat "$PID_FILE")"
  else
    rm -f "$PID_FILE"
    echo "watchnote is not running"
  fi
  ;;
run)
  run_watcher
  ;;
-h | --help | help)
  usage
  ;;
*)
  usage
  exit 1
  ;;
esac
