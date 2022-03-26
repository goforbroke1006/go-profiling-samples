#!/bin/bash

function kill_by_port() {
  PORT=$1
  lsof -i ":${PORT}" | awk '{print $2}' | tail -n +2 | xargs -I PID kill -9 PID
  sleep 0.1
}

function wait_port_listening() {
  PORT=$1
  while ! nc -z localhost "${PORT}"; do sleep 0.1; done
  sleep 0.1
}

DURATION=20
LOAD_CONCURRENCY=25

SERVER_ON_STACK_PORT=8001
SERVER_ON_HEAP_PORT=8002
SERVER_ON_HEAP_POOL_PORT=8003

function run_profiling() {
  IMPL_PATH=$1
  PORT=$2
  COMPONENT_NAME=$(echo "$1" | sed 's#/#-#g')
  DURATION=$3

  echo "Process ${COMPONENT_NAME} sample..."

  rm -f ${IMPL_PATH}/*.out ${IMPL_PATH}/*.txt
  rm -f server

  go build -gcflags='-m' -o ${IMPL_PATH}/server ${IMPL_PATH}/main.go >${IMPL_PATH}/build.txt 2>&1
  kill_by_port "${PORT}"
  export GODEBUG=gctrace=1
  "${IMPL_PATH}/server" ${PORT} >${IMPL_PATH}/server.txt 2>&1 &
  wait_port_listening "${PORT}"
  hey -c ${LOAD_CONCURRENCY} -z "${DURATION}s" http://localhost:${PORT}/numbers >"${IMPL_PATH}/hey.txt" &
  ./profiling-web.sh "${COMPONENT_NAME}" localhost:${PORT} ${DURATION}
  kill_by_port "${PORT}"
}

run_profiling 06_gc_demo/responses_on_stack ${SERVER_ON_STACK_PORT} ${DURATION}
run_profiling 06_gc_demo/responses_on_heap ${SERVER_ON_HEAP_PORT} ${DURATION}
run_profiling 06_gc_demo/responses_on_ptr_pool ${SERVER_ON_HEAP_POOL_PORT} ${DURATION}

kill_by_port 18001
kill_by_port 18002

#go tool trace -http=:18001 ".profiling/GC-demo-on-stack/trace.out" &
#go tool trace -http=:18002 ".profiling/GC-demo-on-heap/trace.out" &

#go tool pprof -web ".profiling/GC-demo-on-stack/profile.out"
#go tool pprof -web ".profiling/GC-demo-on-heap/profile.out"

read -n 1 -s -r -p "Press any key to continue..."

#kill_by_port ${SERVER_ON_STACK_PORT}
#kill_by_port ${SERVER_ON_HEAP_PORT}
#kill_by_port ${SERVER_ON_HEAP_POOL_PORT}
kill_by_port 18001
kill_by_port 18002
