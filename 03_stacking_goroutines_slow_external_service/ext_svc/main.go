package main

import (
	"fmt"
	"net/http"
	"time"
)

func main() {
	http.HandleFunc("/slow-echo", func(rw http.ResponseWriter, req *http.Request) {
		time.Sleep(2500 * time.Millisecond)

		fmt.Println("send answer")
		rw.WriteHeader(http.StatusOK)
		rw.Write([]byte("pss, do you wanna some processing lag"))
	})
	http.ListenAndServe("0.0.0.0:8888", nil)
}
