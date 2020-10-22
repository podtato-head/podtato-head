package main

import (
	"fmt"
	"html/template"
	"net/http"
	"os"
)

var serviceVersion string
var overviewTemplate *template.Template

type Overview struct {
	Version string
}

// create a handler struct
type HTTPHandler struct{}

// implement `ServeHTTP` method on `HttpHandler` struct
func (h HTTPHandler) ServeHTTP(res http.ResponseWriter, req *http.Request) {

	// fmt.Fprintf(res, "<html><head><title>Hello server</title><link rel=\"stylesheet\" href=\"./static/styles.css\" href=</head><body>")
	// fmt.Fprintf(res, "<h1>Hello from podtato head - Version %s </h1>", version)
	// fmt.Fprintf(res, "</body</html>")

	overviewData := Overview{
		Version: serviceVersion,
	}

	overviewTemplate.Execute(res, overviewData)
}

func main() {

	// expecting version as first parameter
	serviceVersion = os.Args[1]

	// load website template
	overviewTemplate = template.Must(template.ParseFiles("./overview.html"))

	// create a new handler
	handler := HTTPHandler{}

	// service static files
	fileServer := http.FileServer(http.Dir("./static"))

	http.Handle("/", handler)
	http.Handle("/static/", http.StripPrefix("/static/", fileServer))
	fmt.Println("Serving requests on port 9000")

	// listen and serve
	http.ListenAndServe(":9000", nil)
}
