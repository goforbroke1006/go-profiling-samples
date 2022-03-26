package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	_ "net/http/pprof"
	"os"
	"strconv"
	"sync"
	"time"
)

const numberCount = 16384

func main() {
	port, _ := strconv.ParseInt(os.Args[1], 10, 64)
	rand.Seed(time.Now().UnixNano())

	intsPool := sync.Pool{
		New: func() interface{} {
			return new(int64)
		},
	}

	http.HandleFunc("/numbers", getNumbersHandle(intsPool))
	panic(http.ListenAndServe(fmt.Sprintf("0.0.0.0:%d", port), nil))
}

func getNumbersHandle(ipool sync.Pool) func(w http.ResponseWriter, req *http.Request) {
	return func(w http.ResponseWriter, req *http.Request) {
		items := make([]*int64, 0, numberCount)
		for i := 0; i < numberCount; i++ {
			n := ipool.Get().(*int64)
			*n = rand.Int63()

			items = append(items, n)
		}
		data, _ := json.Marshal(items)
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write(data)
	}
}
