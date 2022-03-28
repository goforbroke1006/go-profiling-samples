package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	_ "net/http/pprof"
	"os"
	"strconv"
	"time"

	common "go-profiling-samples/06_gc_demo"
)

func main() {
	port, _ := strconv.ParseInt(os.Args[1], 10, 64)
	rand.Seed(time.Now().UnixNano())

	http.HandleFunc("/numbers", getNumbersHandle)
	panic(http.ListenAndServe(fmt.Sprintf("0.0.0.0:%d", port), nil))
}

func getNumbersHandle(w http.ResponseWriter, req *http.Request) {
	block := make(common.BlockType, common.BlockSize)
	rand.Read(block)

	items := make([]*common.HugeStructure, 0, common.SamplesCount)
	for i := 0; i < common.SamplesCount; i++ {
		item := new(common.HugeStructure)

		item.ID = rand.Int63()
		item.Description = common.Text
		item.FistName = "Foo"
		item.LastName = "Bar"
		item.BirthDay = time.Unix(1234567890, 0)
		item.Weight = 50
		item.Height = 170

		copy(item.Block1, block)
		copy(item.Block2, block)
		copy(item.Block3, block)
		copy(item.Block4, block)
		copy(item.Block5, block)
		copy(item.Block6, block)
		copy(item.Block7, block)
		copy(item.Block8, block)

		items = append(items, item)
	}
	data, _ := json.Marshal(items)
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(data)
}
