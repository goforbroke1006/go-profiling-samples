# 06_gc_demo

### How to run

```shell
bash 06_gc_demo/run.sh
```

And open next files to check request count proceed for each server implementation.

* 06_gc_demo/responses_on_stack/hey.txt
* 06_gc_demo/responses_on_heap/hey.txt
* 06_gc_demo/responses_on_ptr_pool/hey.txt

### Or run benchmark

```shell
go test ./... -bench="Benchmark_([\w]+)_getNumbersHandle" -benchmem -test.benchtime=20x -test.parallel=5 | grep "_getNumbersHandle-"
go test ./... -bench="Benchmark_([\w]+)_getNumbersHandle" -benchmem -test.benchtime=5s -test.parallel=1000 | grep "_getNumbersHandle-"
go test ./... -bench="Benchmark_([\w]+)_getNumbersHandle" -benchmem -test.benchtime=10s -test.parallel=10 | grep "_getNumbersHandle-"
go test ./... -bench="Benchmark_([\w]+)_getNumbersHandle" -benchmem -test.benchtime=200x -test.parallel=50 | grep "_getNumbersHandle-"

go test ./... -bench="Benchmark_values_getNumbersHandle" -benchmem -benchtime 2000x
go test ./... -bench="Benchmark_pointers_getNumbersHandle" -benchmem -benchtime 2000x
go test ./... -bench="Benchmark_pointers_pool_getNumbersHandle" -benchmem -benchtime 2000x
```



```shell
go test ./... -bench="Benchmark_([\w]+)_getNumbersHandle" -benchmem -test.benchtime=10s -test.parallel=10 | grep "_getNumbersHandle-"
```

```txt
Benchmark_pointers_getNumbersHandle-16             10000           1080030 ns/op         1735943 B/op       1027 allocs/op
Benchmark_pointers_pool_getNumbersHandle-16         9740           1045711 ns/op         1620795 B/op        515 allocs/op
Benchmark_values_getNumbersHandle-16                9664           1050404 ns/op         1773261 B/op        515 allocs/op
```

### How to read GC debug outputs

From https://www.ardanlabs.com/blog/2019/05/garbage-collection-in-go-part2-gctraces.html

```txt
gc 2553 @8.452s 14%: 0.004+0.33+0.051 ms clock, 0.056+0.12/0.56/0.94+0.61 ms cpu, 4->4->2 MB, 5 MB goal, 12 P

gc 2553     : The 2553 GC runs since the program started
@8.452s     : Eight seconds since the program started
14%         : Fourteen percent of the available CPU so far has been spent in GC

// wall-clock
0.004ms     : STW        : Write-Barrier - Wait for all Ps to reach a GC safe-point.
0.33ms      : Concurrent : Marking
0.051ms     : STW        : Mark Term     - Write Barrier off and clean up.

// CPU time
0.056ms     : STW        : Write-Barrier
0.12ms      : Concurrent : Mark - Assist Time (GC performed in line with allocation)
0.56ms      : Concurrent : Mark - Background GC time
0.94ms      : Concurrent : Mark - Idle GC time
0.61ms      : STW        : Mark Term

4MB         : Heap memory in-use before the Marking started
4MB         : Heap memory in-use after the Marking finished
2MB         : Heap memory marked as live after the Marking finished
5MB         : Collection goal for heap memory in-use after Marking finished

// Threads
12P         : Number of logical processors or threads used to run Goroutines.
```