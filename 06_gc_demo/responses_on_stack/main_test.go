package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func Benchmark_values_getNumbersHandle(b *testing.B) {
	req, err := http.NewRequest(http.MethodGet, "/numbers", nil)
	if err != nil {
		b.Fatal(err)
	}

	// We create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response.
	rr := httptest.NewRecorder()

	handler := http.HandlerFunc(getNumbersHandle)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		handler.ServeHTTP(rr, req)
	}

}
