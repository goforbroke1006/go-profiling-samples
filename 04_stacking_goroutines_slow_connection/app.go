package main

import (
	"math/rand"
	"net/http"
	"sort"
	"time"
)

func NewDaemonizedTask() *daemonizedTask {
	return &daemonizedTask{
		repeatPeriod: 5 * time.Second,
		stuckPeriod:  12 * time.Second,
	}
}

type daemonizedTask struct {
	repeatPeriod time.Duration
	stuckPeriod  time.Duration

	stopInit chan struct{}
	stopDone chan struct{}
}

func (t daemonizedTask) Run() {
	ticker := time.NewTicker(t.repeatPeriod)

LOOP:
	for {
		select {
		case <-t.stopInit:
			break LOOP
		case <-ticker.C:
			go t.process()
		}
	}
}

func (t daemonizedTask) Stop() {
	t.stopInit <- struct{}{}
	<-t.stopDone
}

func (t daemonizedTask) process() {
	const size = 16777216

	var numbers []int
	for i := 0; i < size; i++ {
		numbers = append(numbers, rand.Int())
	}

	sort.Ints(numbers)

	// fake job
	time.Sleep(t.stuckPeriod)

	const repeatNetworkUsage = 5
	for i := 0; i < repeatNetworkUsage; i++ {
		_, _ = http.Get("https://www.google.com/")
	}
}
