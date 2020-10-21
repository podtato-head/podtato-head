package main

import (
	"fmt"
	"net/http"
	"os"
)

var version string

// create a handler struct
type HTTPHandler struct{}

	// implement `ServeHTTP` method on `HttpHandler` struct
	func (h HTTPHandler) ServeHTTP(res http.ResponseWriter, req *http.Request){ 

		fmt.Fprintf(res, "<html><head><title>Hello server</title></head><body>")
		fmt.Fprintf(res, "<h1>Hello World! - Version %s </h1>", version)
		fmt.Fprintf(res, "</body</html>")
	}

func main() {

	// expecting version as first parameter
	version = os.Args[1]

	fs := http.FileServer(http.Dir("./static"))
	http.Handle ("/static/", fs)
	// create a new handler
	handler := HTTPHandler{} 
	http.Handle ("/", handler)

	fmt.Println("Serving requests on port 9000")
	// listen and serve
	http.ListenAndServe(":9000", nil)

}
