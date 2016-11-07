#!/bin/bash

### BEGIN INIT INFO
# Provides:          Red Hat Service Daemon Template
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Red Hat Service Daemon Template
### END INIT INFO

# Generic Init.d Script for RHEL <= 6
# Set Below Variables
# By Levon Becker
# Last Updated 11/25/2014

# region Edit These Variables
servicename=myserviced
binary=/bin/bash
script=/opt/application/runscript.sh
logfile=/var/log/myserviced/myserviced.log
pidfile=/var/run/myserviced/myserviced.pid
user=myservice
# endregion Edit These Variables

program="$binary $script"

return_value=0

ensure_piddir() {
    pid_dir=`dirname ${pidfile}`
    if [ ! -d ${pid_dir} ]; then
        mkdir -p ${pid_dir}
        chown -R ${user} ${pid_dir}
        chmod 755 ${pid_dir}
    fi
}

search_pidproc() {
  pid=
  pid_running=false
  pid=$(pgrep -P1 -fl "$program" | grep -v grep | grep -v bash | cut -f1 -d" ")
  # If string not empty = true
  if [ $pid ]; then
    pid_running=true
  fi
}

get_pidfile() {
  pid=
  read pid < "$pidfile"
}

check_pidproc() {
  pid_found=false
  if [ "$pid" ]; then
    ps -p $pid > /dev/null
    if [ $? -eq 0 ]; then
      pid_found=true
      echo "  Service $servicename $pid [ RUNNING ]"
    else
      echo "  Service $servicename $pid [ STOPPED ]"
    fi
  else
    echo "  Service $servicename $pid [ STOPPED ]"
  fi

  #return $pid_found
}

check_pidfile() {
  # Check if File Exists
  pidfile_exists=false
  if [ -f "$pidfile" ]; then
    pidfile_exists=true
    #echo '  PID File Found'
  #else
    #echo '  PID File Not Found'
  fi

  # Check if File Empty
  pidfile_empty=true
  if $pidfile_exists; then
    get_pidfile
    # If file not empty = true
    # TODO: Not sure this condition is working
    if [ -n "$pid" ]; then
      pidfile_empty=false
      #echo '  PID File Healthy'
    #else
      #echo '  PID File Empty'
    fi
  fi
}

run_program() {
  echo "  Starting $servicename..."
  ensure_piddir
  #local CMD="$SCRIPT &> \"$LOGFILE\" & echo \$!"
  #su -c "$CMD" $RUNAS > "$PIDFILE"
  su -c $program &> $logfile & echo $! $user > $pidfile

  read pid < $pidfile
  sleep 1
  # Check pid Running
  check_pidproc
}

check_stopped() {
  echo "  Stopping $servicename $pid..."
  sleep 5
  # Get child pid/s
  #childpid=
  # Wait for Parent pid to stop
  #while [ -n $(ps -ef | grep $(cat "$pidfile") | grep "$program" | grep -v grep | grep -v bash) || $count -gt 60 ]
  #do
  # sleep 1
  # count=$[$count+1]
  #done
  if [ $? -eq 0 ]; then
    echo '  Service Stopped [  OK  ]'
  else
    return_value=1
  fi
  #echo '  Service Stopped [  OK  ]' >&2
}

start() {
  echo 'Starting Service...'
  # Check if pid File Exists and/or Empty
  check_pidfile
  # File Found and Not Empty
  if $pidfile_exists && ! $pidfile_empty; then
    get_pidfile
    check_pidproc
    if $pid_found; then
      echo "  $servicename $pid Already Running"
    else
      echo '  Process not currently running'
      run_program
    fi
  # File Found, but Empty
  elif $pidfile_exists && $pidfile_empty; then
    search_pidproc
    if ! $pid_running; then
      run_program
    else
      echo '  Process Already Running'
      echo '    Service Start [ FAILED ]'
      return_value=1
    fi
  # File not found
  else
    search_pidproc
    if ! $pid_running; then
      run_program
    else
      echo '  Process Already Running'
      echo '    Service Start [ FAILED ]'
      return_value=1
    fi
  fi
  return $return_value
}

stop() {
  # TODO: Stop all pids running if multiple?
  echo 'Stopping Service…'
  # Try pid File First
  check_pidfile
  if $pidfile_exists && ! $pidfile_empty; then
    # Pull pid from File
    get_pidfile
  else
    # Look for running pid
    search_pidproc
  fi
  check_pidproc

  if $pid_found; then
    # TODO: If kill fails because wrong PID in file PIDFile not removed.
    kill $pid && rm -f "$pidfile"
    check_stopped
  fi
  return $return_value
}

status() {
  # First try "ps"
  echo 'Checking Service...'
  check_pidfile
  if $pidfile_exists && ! $pidfile_empty; then
    # Pull pid from File
    # TODO: IF PIDFile has wrong PID this fails
    get_pidfile
  else
    # Look for running pid
    search_pidproc
  fi
  check_pidproc
return $return_value
}

case "$1" in
  start)
    start
    return_value=$?
    ;;
  stop)
    stop
    return_value=$?
    ;;
  status)
    status
    return_value=$?
    ;;
  restart|reload)
    stop
    start
    return_value=$?
    ;;
  *)
  echo "Usage: $0 {start|stop|restart|reload|status}"
  return_value=2
esac

exit $return_value
