#!/bin/bash

### BEGIN INIT INFO
# Provides:          <%= @service_name %>
# Required-Start:    $syslog $remote_fs
# Required-Stop:     $syslog $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: New Relic <%= @plugin_name %> Plugin
# Description:       Controls the New Relic <%= @plugin_name %> Plugin
### END INIT INFO

RUNAS="<%= @user %>"
NAME="<%= @service_name %>"
VERSION="<%= @version %>"
DAEMON="<%= @daemon %>"
DAEMONDIR="<%= @daemon_dir %>"
PIDFILE=/var/run/$NAME.pid

get_pid() {
  local my_pid
  if [ -f "$PIDFILE" ]; then
    my_pid="$(cat "$PIDFILE")"
    if [ -z "$my_pid" ]; then
      echo "pidfile exists but is empty: $PIDFILE" >&2
      return 5
    fi
    echo "$my_pid"
  else
    echo "No pidfile exists at $PIDFILE" >&2
    return 4
  fi
}

is_running() {
  get_pid > /dev/null 2>&1 &&
    ps "$(get_pid)" > /dev/null 2>&1
}

start() {
  if is_running; then
    echo "Already Started $NAME"
  else
    echo "Starting $NAME"
    cd "$DAEMONDIR" || exit 4
    touch "$PIDFILE"
    chown "$RUNAS" "$PIDFILE"
    su "$RUNAS" -s '/bin/bash' -c "<%= @run_command %> $DAEMON >> $DAEMONDIR/plugin_daemon.log 2>&1 & echo \$! > $PIDFILE"
  fi
}

status() {
  if is_running; then
    echo "$NAME $VERSION is running"
  else
    echo "$NAME $VERSION is stopped"
    exit 1
  fi
}

stop() {
  if is_running; then
    echo "Stopping $NAME"
    kill "$(get_pid)"
  else
    echo "$NAME is not running"
  fi
}

restart() {
  stop
  sleep 1
  start
}

case "${1}" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart)
    restart
    ;;
  *)
    echo "Usage: ${0} {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0
