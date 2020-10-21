package main

import (
	"fmt"
	"net/http"
	"os"
)

var version string

// create a handler struct
type HttpHandler struct{}

	// implement `ServeHTTP` method on `HttpHandler` struct
	func (h HttpHandler) ServeHTTP(res http.ResponseWriter, req *http.Request){ 

		fmt.Fprintf(res, "<html><head><title>Hello server</title></head><body>")
		fmt.Fprintf(res, "<h1>Hello World! - Version %s </h1>", version)
		fmt.Fprintf(res, "</body</html>")
	}

func main() {

	// expecting version as first parameter
	version = os.Args[1]

	// create a new handler
	handler := HttpHandler{} 

	fmt.Println("Serving requests on port 9000")
	// listen and serve
	http.ListenAndServe(":9000", handler)

}
