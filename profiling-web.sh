#!/bin/bash

# https://stackoverflow.com/questions/64057727/is-it-ok-to-use-golang-pprof-on-production-without-effecting-performance

# go tool pprof http://localhost:8080/debug/pprof/profile
# go tool pprof http://localhost:8080/debug/pprof/heap
# go tool pprof http://localhost:8080/debug/pprof/profile?seconds=30

#go tool pprof -http=:4001 trace.out "http://${LISTENER_ADDR}/debug/pprof/trace?seconds=${PROFILING_DURATION}" &
#go tool pprof -http=:4002 profile.out "http://${LISTENER_ADDR}/debug/pprof/profile?seconds=${PROFILING_DURATION}" &
#go tool pprof -http=:4003 heap.out "http://${LISTENER_ADDR}/debug/pprof/heap?seconds=${PROFILING_DURATION}" &

# bash ./profiling.sh pricing-pricer-BO localhost:8080 60

if [[ $1 == "help" ]] || [[ $1 == "?" ]]; then
  echo "Usage:"
  echo "    bash ./$(basename "$0") pricing-pricer-BO localhost:8080 30"
  echo ""
  echo "This mean script should listen localhost:8080/debug/pprof/<SOME-PROFILE-KIND> during 30 seconds"
  exit 0
fi

# get args
COMPONENT_NAME=${1:-default}
LISTENER_ADDR=${2:-localhost:8080}
PROFILING_DURATION=${3:-60}

# validate
digits_re='^[0-9]+$'
if ! [[ $PROFILING_DURATION =~ $digits_re ]]; then
  echo "ERROR: Profiling duration (third parameter) should be number!" >&2
  exit 1
fi

mkdir -p ".profiling/${COMPONENT_NAME}/"

rm -f ".profiling/${COMPONENT_NAME}/trace.out"
rm -f ".profiling/${COMPONENT_NAME}/profile.out"
rm -f ".profiling/${COMPONENT_NAME}/heap.out"
rm -f ".profiling/${COMPONENT_NAME}/allocs.out"
rm -f ".profiling/${COMPONENT_NAME}/goroutine.out"

curl --silent "http://${LISTENER_ADDR}/debug/pprof/trace?seconds=${PROFILING_DURATION}" >".profiling/${COMPONENT_NAME}/trace.out" &
PID_TRACE=$!
curl --silent "http://${LISTENER_ADDR}/debug/pprof/profile?seconds=${PROFILING_DURATION}" >".profiling/${COMPONENT_NAME}/profile.out" &
PID_PROFILE=$!
curl --silent "http://${LISTENER_ADDR}/debug/pprof/heap?seconds=${PROFILING_DURATION}" >".profiling/${COMPONENT_NAME}/heap.out" &
PID_HEAP=$!
curl --silent "http://${LISTENER_ADDR}/debug/pprof/allocs?seconds=${PROFILING_DURATION}" >".profiling/${COMPONENT_NAME}/allocs.out" &
PID_ALLOCS=$!
curl --silent "http://${LISTENER_ADDR}/debug/pprof/goroutine?seconds=${PROFILING_DURATION}" >".profiling/${COMPONENT_NAME}/goroutine.out" &
PID_GOROUTINE=$!

# display how many time left
while [[ $i -ne ${PROFILING_DURATION} ]]; do
  i=$(($i + 1))
  left=$((PROFILING_DURATION - i))
  echo -ne "Wait ${left} seconds for all profiles readiness...    \r"
  sleep 1
done
echo -ne "                                                                                                           \r"

wait -n ${PID_TRACE} ${PID_PROFILE} ${PID_HEAP} ${PID_ALLOCS} ${PID_GOROUTINE}
sleep 2

echo "go tool trace .profiling/${COMPONENT_NAME}/trace.out"

go tool pprof -top ".profiling/${COMPONENT_NAME}/profile.out" >".profiling/${COMPONENT_NAME}/profile.top.txt"
go tool pprof -top ".profiling/${COMPONENT_NAME}/heap.out" >".profiling/${COMPONENT_NAME}/heap.top.txt"

go tool pprof -top -inuse_space ".profiling/${COMPONENT_NAME}/heap.out" >".profiling/${COMPONENT_NAME}/heap.inuse_space.top.txt"
go tool pprof -top -inuse_objects ".profiling/${COMPONENT_NAME}/heap.out" >".profiling/${COMPONENT_NAME}/heap.inuse_objects.top.txt"
go tool pprof -top -alloc_space ".profiling/${COMPONENT_NAME}/heap.out" >".profiling/${COMPONENT_NAME}/heap.alloc_space.top.txt"
go tool pprof -top -alloc_objects ".profiling/${COMPONENT_NAME}/heap.out" >".profiling/${COMPONENT_NAME}/heap.alloc_objects.top.txt"

go tool pprof -png ".profiling/${COMPONENT_NAME}/profile.out" >".profiling/${COMPONENT_NAME}/profile.png"

go tool pprof -png -inuse_space ".profiling/${COMPONENT_NAME}/heap.out" >".profiling/${COMPONENT_NAME}/heap.inuse_space.png"
go tool pprof -png -inuse_objects ".profiling/${COMPONENT_NAME}/heap.out" >".profiling/${COMPONENT_NAME}/heap.inuse_objects.png"
go tool pprof -png -alloc_space ".profiling/${COMPONENT_NAME}/heap.out" >".profiling/${COMPONENT_NAME}/heap.alloc_space.png"
go tool pprof -png -alloc_objects ".profiling/${COMPONENT_NAME}/heap.out" >".profiling/${COMPONENT_NAME}/heap.alloc_objects.png"

go tool pprof -png ".profiling/${COMPONENT_NAME}/allocs.out" >".profiling/${COMPONENT_NAME}/allocs.png"

go tool pprof -png ".profiling/${COMPONENT_NAME}/goroutine.out" >".profiling/${COMPONENT_NAME}/goroutine.png"

echo "See https://git.io/JfYMW for how to read the graph"
echo "Finished!"

exit 0 # TODO: next steps are not ready to run

go tool trace ".profiling/${COMPONENT_NAME}/trace.out" &
go tool pprof -web ".profiling/${COMPONENT_NAME}/profile.out" &
go tool pprof -web ".profiling/${COMPONENT_NAME}/heap.out" &
