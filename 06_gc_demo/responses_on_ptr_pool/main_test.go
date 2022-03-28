package main

import (
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"

	common "go-profiling-samples/06_gc_demo"
)

func Benchmark_pointers_pool_getNumbersHandle(b *testing.B) {
	req, err := http.NewRequest(http.MethodGet, "/numbers", nil)
	if err != nil {
		b.Fatal(err)
	}

	// We create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response.
	rr := httptest.NewRecorder()

	pool := &sync.Pool{
		New: func() interface{} {
			return new(common.HugeStructure)
		},
	}
	handler := http.HandlerFunc(getNumbersHandle(pool))

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		handler.ServeHTTP(rr, req)
	}

}
