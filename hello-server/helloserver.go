package main

import (
	"fmt"
	"net/http"
)

// create a handler struct
type HttpHandler struct{}

	// implement `ServeHTTP` method on `HttpHandler` struct
	func (h HttpHandler) ServeHTTP(res http.ResponseWriter, req *http.Request){ 

		fmt.Fprintf(res, "<html><head><title>Hello server</title></head><body>")
		fmt.Fprintf(res, "<h1>Hello World! - Version 0.1.0</h1>")
		fmt.Fprintf(res, "</body</html>")
	}

func main() {

	// create a new handler
	handler := HttpHandler{}

	fmt.Println("Serving requests on port 9000")
	// listen and serve
	http.ListenAndServe(":9000", handler)

}
