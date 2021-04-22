# staking goroutines

```bash
cd 01_staking_goroutines
wget -O trace.out http://localhost:8080/debug/pprof/trace?seconds=60
go tool trace trace.out
```

### Summary

<img src="trace/01-main.daemonizedTask.process.png" alt="goroutines report"/>

All goroutines spend about 16 seconds.

4 seconds for sorting random numbers.

12 seconds sleeping.

Red part means "execution time".

Dark grey means "sleep/idle time" I guess.

<img src="trace/02-net.http.(*connReader).backgroundRead.png" alt="goroutines report"/>

**backgroundRead** has fast (45µs) "Execution" and long (60s) "Network wait" time.

Maybe it's process, that serve trace collection HTTP request.

<img src="trace/03-net.(*Resolver).goLookupIPCNAMEOrder.func3.1.png" alt="goroutines report"/>
