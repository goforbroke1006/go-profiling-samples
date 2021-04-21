# staking goroutines with slow network connection

Install util for network lag emulation

```bash
sudo apt update
sudo apt-get install iproute2
```

Add 250ms lag

```bash
# my network interface is "wlp1s0"
export MY_NETWORK_INTERFACE=wlp1s0
sudo tc qdisc add dev ${MY_NETWORK_INTERFACE} root netem delay 250ms
```

Run application

Let's start to collect trace:

```bash
cd 02_stacking_goroutines_slow_network
wget -O trace.out http://localhost:8080/debug/pprof/trace?seconds=60
go tool trace trace.out
```

Disable network lag

```bash
sudo tc qdisc del dev ${MY_NETWORK_INTERFACE} root netem
```

### Summary

<img src="goroutine-analysis.png" alt="goroutines report"/>

I expect "Network wait" should be greater than 0.

However, "Network wait" was not changed and "Sync block" equals ~1500ms.