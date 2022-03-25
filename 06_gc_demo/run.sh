#!/bin/bash

function kill_by_port() {
  PORT=$1
  lsof -i ":${PORT}" | awk '{print $2}' | tail -n +2 | xargs -I PID kill -9 PID
  sleep 0.1
}

function wait_port_listening() {
  PORT=$1
  while ! nc -z localhost "${PORT}"; do
    sleep 0.1
  done
  sleep 0.1
}

DURATION=20
LOAD_CONCURRENCY=25

SERVER_ON_STACK_PORT=8001
SERVER_ON_HEAP_PORT=8002

kill_by_port ${SERVER_ON_STACK_PORT}
kill_by_port ${SERVER_ON_HEAP_PORT}
kill_by_port 18001
kill_by_port 18002


mkdir -p ".profiling/GC-demo-on-stack/"
mkdir -p ".profiling/GC-demo-on-heap/"


go run 06_gc_demo/responses_on_stack/main.go ${SERVER_ON_STACK_PORT} &
SERVER_PID=$!
wait_port_listening ${SERVER_ON_STACK_PORT}
hey -c ${LOAD_CONCURRENCY} -z "${DURATION}s" http://localhost:${SERVER_ON_STACK_PORT}/numbers >".profiling/GC-demo-on-stack/hey.out" &
./profiling-web.sh GC-demo-on-stack localhost:${SERVER_ON_STACK_PORT} ${DURATION}
kill -9 ${SERVER_PID}


go run 06_gc_demo/responses_on_heap/main.go ${SERVER_ON_HEAP_PORT} &
SERVER_PID=$!
wait_port_listening ${SERVER_ON_HEAP_PORT}
hey -c ${LOAD_CONCURRENCY} -z "${DURATION}s" http://localhost:${SERVER_ON_HEAP_PORT}/numbers >".profiling/GC-demo-on-heap/hey.out" &
./profiling-web.sh GC-demo-on-heap localhost:${SERVER_ON_HEAP_PORT} ${DURATION}
kill -9 ${SERVER_PID}




go tool trace -http=:18001 ".profiling/GC-demo-on-stack/trace.out" &
go tool trace -http=:18002 ".profiling/GC-demo-on-heap/trace.out" &

#go tool pprof -web ".profiling/GC-demo-on-stack/profile.out"
#go tool pprof -web ".profiling/GC-demo-on-heap/profile.out"

read -n 1 -s -r -p "Press any key to continue..."

kill_by_port ${SERVER_ON_STACK_PORT}
kill_by_port ${SERVER_ON_HEAP_PORT}
kill_by_port 18001
kill_by_port 18002
