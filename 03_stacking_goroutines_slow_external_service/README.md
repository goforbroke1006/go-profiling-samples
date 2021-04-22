# staking goroutines with slow external service

Run ext_svc application

Run main application

Let's start to collect trace:

```bash
cd 03_stacking_goroutines_slow_external_service
wget -O trace.out http://localhost:8080/debug/pprof/trace?seconds=60
go tool trace trace.out
```

### Summary

<img src="trace/01-main.daemonizedTask.process.png" alt="goroutines report"/>

<strike>Slow external service, that sleep (2500ms) before answer, can't change "Network wait" metric too.</strike>

"Network wait" was not changed and "Sync block" equals ~12s.</strike>

<img src="trace/02-net.http.(*persistConn).readLoop.png" alt="goroutines report"/>

This panel show how slow external server affect my app.

<img src="trace/03-net.http.(*persistConn).writeLoop.png" alt="goroutines report"/>

No idea what is that.
