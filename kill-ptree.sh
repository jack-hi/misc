#!/bin/sh
#
# Kill all the process[PID] and its children

#set -x

PID=$1

if [ x"${PID}" = x -o ! -d /proc/${PID} ]; then
  exit 1
fi

indent=0
iterate_kill() {
  : $((indent ++))

  local _pid=$1
  printf "%$((4 * indent))s" "-"
  printf " Killing process: %d\n" "${_pid}"
  while :; do
    local _cnt=0
    ps -ef | eval awk \'{if\(\$3==${_pid}\) print \$2}\' |
    while read p; do
      : $((_cnt ++))
      iterate_kill $p
    done

    if [ ${_cnt} -eq 0 ]; then
      kill -KILL ${_pid}
      break
    fi
  done

  : $((indent --))
}

echo "Start to kill process with PID: ${PID} and its children"
iterate_kill ${PID}

exit 0