#!/bin/bash

set -e

function kill_by_port() {
  PORT=$1
  #  lsof -i ":${PORT}" | awk '{print $2}' | tail -n +2 | xargs -I PID kill -9 PID
  kill -9 $(lsof -i ":${PORT}" | awk '{print $2}' | tail -n +2) || true
  sleep 0.1
}

function wait_port_listening() {
  PORT=$1
  while ! nc -z localhost "${PORT}"; do sleep 0.1; done
  sleep 0.1
}

PROF_TIMOUT=60
PROF_DURATION=10
LOAD_DURATION=300
LOAD_CONCURRENCY=25

SERVER_ON_STACK_PORT=8001
SERVER_ON_HEAP_PORT=8002
SERVER_ON_HEAP_POOL_PORT=8003

function run_profiling() {
  IMPL_PATH=$1
  PORT=$2
  COMPONENT_NAME=$(echo "$1" | sed 's#/#-#g')

  echo "Process ${COMPONENT_NAME} sample..."

  rm -f "${IMPL_PATH}/*.out"
  rm -f "${IMPL_PATH}/*.txt"
  rm -f "${IMPL_PATH}/server"

  go build -gcflags='-m' -o "${IMPL_PATH}/server" "${IMPL_PATH}/main.go" >"${IMPL_PATH}/build.txt" 2>&1
  echo "  build ready..."
  #kill_by_port "${PORT}" >/dev/null 2>&1
  #export GODEBUG=gctrace=1
  "${IMPL_PATH}/server" "${PORT}" &
  #  SERVER_PID=$!
  wait_port_listening "${PORT}"
  echo "  server ready..."

  (
    sleep ${PROF_TIMOUT}
    echo "  start profiling..."
    ./profiling-web.sh "${COMPONENT_NAME}" "localhost:${PORT}" ${PROF_DURATION}
  ) &

  echo "  start loading..."
  hey -c ${LOAD_CONCURRENCY} -z "${LOAD_DURATION}s" "http://localhost:${PORT}/numbers" >"${IMPL_PATH}/hey.txt"
  echo "  hey stopped..."
  #  kill -9 ${SERVER_PID}
  echo "  start server killing..."
  kill_by_port "${PORT}" >/dev/null 2>&1
  echo "  kill server..."
  sleep 5
}

kill_by_port ${SERVER_ON_STACK_PORT}
kill_by_port ${SERVER_ON_HEAP_PORT}
kill_by_port ${SERVER_ON_HEAP_POOL_PORT}

run_profiling 06_gc_demo/responses_on_stack ${SERVER_ON_STACK_PORT}
run_profiling 06_gc_demo/responses_on_heap ${SERVER_ON_HEAP_PORT}
run_profiling 06_gc_demo/responses_on_ptr_pool ${SERVER_ON_HEAP_POOL_PORT}

#kill_by_port 18001
#kill_by_port 18002

#go tool trace -http=:18001 ".profiling/06_gc_demo-responses_on_stack/trace.out" &
#go tool trace -http=:18002 ".profiling/06_gc_demo-responses_on_heap/trace.out" &
#go tool trace -http=:18003 ".profiling/06_gc_demo-responses_on_ptr_pool/trace.out" &

#go tool pprof -web ".profiling/GC-demo-on-stack/profile.out"
#go tool pprof -web ".profiling/GC-demo-on-heap/profile.out"

read -n 1 -s -r -p "Press any key to continue..."
echo ""

#kill_by_port ${SERVER_ON_STACK_PORT}
#kill_by_port ${SERVER_ON_HEAP_PORT}
#kill_by_port ${SERVER_ON_HEAP_POOL_PORT}
#kill_by_port 18001
#kill_by_port 18002
