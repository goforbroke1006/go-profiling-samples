package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"
)
import _ "net/http/pprof"

func main() {
	go func() {
		log.Println(http.ListenAndServe("localhost:8080", nil))
	}()

	tp := &http.Transport{
		IdleConnTimeout:     1 * time.Second,
		MaxIdleConns:        1,
		MaxConnsPerHost:     1,
		MaxIdleConnsPerHost: 1,
	}
	client := &http.Client{
		Timeout:   60 * time.Second,
		Transport: tp,
	}

	time.Sleep(10 * time.Second)
	sendReqPrintResp(client, "https://www.google.com/")
	sendReqPrintResp(client, "https://github.com/")
	sendReqPrintResp(client, "https://m.vk.com/")
	sendReqPrintResp(client, "https://stackoverflow.com/")
	sendReqPrintResp(client, "https://www.google.com/")
	time.Sleep(10 * time.Second)
}

func sendReqPrintResp(client *http.Client, urlAddr string) {
	// reset cached connection to simplify logs
	client.Transport.(*http.Transport).CloseIdleConnections()

	resp, err := client.Get(urlAddr)
	if err != nil {
		fmt.Println("ERROR:", err.Error())
		return
	}

	defer resp.Body.Close()

	fmt.Println("Status:", resp.Status, resp.StatusCode)
	bytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}
	respContent := strings.TrimSpace(string(bytes))[:16]
	fmt.Println("Body:", respContent)
}
