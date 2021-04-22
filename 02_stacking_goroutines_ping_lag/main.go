package main

import (
	"log"
	"net/http"
	"time"
)
import _ "net/http/pprof"

func main() {
	go func() {
		log.Println(http.ListenAndServe("localhost:8080", nil))
	}()

	task := NewDaemonizedTask()
	go task.Run()
	defer task.Stop()

	time.Sleep(15 * time.Minute) // FIXME: wait for Ctrl+C
}
