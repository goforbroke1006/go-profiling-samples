# 05_http_req

```
GODEBUG='http2debug=0,http2debug=1,http2debug=2'
```

```bash
cd 05_http_req
wget -O trace.out http://localhost:8080/debug/pprof/trace?seconds=15
go tool trace trace.out
```

### Summary

Most interesting call stacks

```txt
net/http.Get at client.go:446                                                               // use wrapper around default http client
  net/http.(*Client).Get at client.go:474                                                   // create req with url and do it (req)
    net/http.(*Client).Do at client.go:585                                                  // do req
      net/http.(*Client).do at client.go:591                                                // do req
        net/http.(*Client).send at client.go:175                                            // append client cookies to req, send req, store cookies from response
          net/http.send at client.go:251                                                    // validate req, add auth headers, starts "round trip" for req
            net/http.(*Transport).RoundTrip at roundtrip.go:17                              // call internal impl
              net/http.(*Transport).roundTrip at transport.go:503                           // create transport req and connect method ??? o__O And get persistConn
              
                sync.(*Once).Do at once.go:59
                  sync.(*Once).doSlow at once.go:68
                    net/http.(*Transport).onceSetNextProtoDefaults-fm at transport.go:360
                      net/http.http2configureTransports at h2_bundle.go:6674
                
                net/http.http2noDialH2RoundTripper.RoundTrip at h2_bundle.go:9197
                  net/http.(*http2Transport).RoundTrip at h2_bundle.go:6942                 // always ErrSkipAltProtocol
                    net/http.(*http2Transport).RoundTripOpt at h2_bundle.go:6968            // connPool empty
                                                                                            
                net/http.rewindBody at transport.go:658                                     // ???
                                                                                            
                net/http.(*Transport).connectMethodForRequest at transport.go:827           // ???
                net/http.(*Transport).getConn at transport.go:1325                          // create wantConn
                                                                                            
                  net/http.(*Transport).queueForIdleConn at transport.go:1001               // push wantConn to wantConnQueue
                    net/http.(*wantConnQueue).pushBack at transport.go:1266                 
                                                                                            
                  net/http.(*Transport).queueForDial at transport.go:1409                   
                    net/http.(*Transport).dialConnFor at transport.go:1440                  // [NEW GOROUTINE]
                
                // pconn.alt.RoundTrip(req)
                net/http.(*http2Transport).RoundTrip at h2_bundle.go:6942
                  net/http.(*http2Transport).RoundTripOpt at h2_bundle.go:6977
                
                net/http.(*Transport).removeIdleConn at transport.go:1090
                  net/http.(*Transport).removeIdleConnLocked at transport.go:1106
```

```txt
net/http.(*Transport).dialConnFor at transport.go:1440
  net/http.(*Transport).dialConn at transport.go:1557                                       // create persistConn, use connectMethod
    net/http.http2configureTransports.func1 at h2_bundle.go:6694                            
      net/http.(*http2clientConnPool).addConnIfNeeded at h2_bundle.go:848                   
        net/http.(*http2addConnCall).run at h2_bundle.go:867                                // [NEW GOROUTINE]
```                                                                                         
                                                                                            
```txt                                                                                      
net/http.(*http2addConnCall).run at h2_bundle.go:867                                        // create http2ClientConn
  net/http.(*http2Transport).NewClientConn at h2_bundle.go:7140                             
    net/http.(*http2Transport).newClientConn at h2_bundle.go:7144                           // ??? o__O
      net/http.(*http2ClientConn).readLoop at h2_bundle.go:8242                             // [NEW GOROUTINE]
```

```txt
net/http.(*Transport).queueForDial at transport.go:1411
  net/http.(*Transport).dialConnFor at transport.go:1448
    net/http.(*Transport).putOrCloseIdleConn at transport.go:887
      net/http.(*Transport).tryPutIdleConn at transport.go:946
        net/http.(*wantConnQueue).popFront at transport.go:1271
```

```txt
net/http.(*http2Transport).newClientConn at h2_bundle.go:7208
  net/http.(*http2ClientConn).readLoop at h2_bundle.go:8244                                 // create http2clientConnReadLoop
    net/http.(*http2clientConnReadLoop).run at h2_bundle.go:8323                            
      net/http.(*http2Framer).ReadFrame at h2_bundle.go:1731                                // read (Ethernet?) frames
```
