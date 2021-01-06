package main

import (
	"fmt"
	"html/template"
	"net/http"
	"os"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var serviceVersion string
var overviewTemplate *template.Template

// create a new counter vector
var getCallCounter = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "http_request_get_total_count", // metric name
		Help: "Number of get requests.",
	},
	[]string{"status"}, // labels
)

type Overview struct {
	Version string
}

// create a handler struct
type HTTPHandler struct{}

// implement `ServeHTTP` method on `HttpHandler` struct
func (h HTTPHandler) ServeHTTP(res http.ResponseWriter, req *http.Request) {

	var status string
	defer func() {
		// increment the counter on defer func
		getCallCounter.WithLabelValues(status).Inc()
	}()

	overviewData := Overview{
		Version: serviceVersion,
	}
	overviewTemplate = template.Must(template.ParseFiles("./overview.html"))
	err := overviewTemplate.Execute(res, overviewData)
	if err != nil {
		status = "error"
	}
	status = "success"
}

func init() {
	prometheus.MustRegister(getCallCounter)
}

func main() {

	// expecting version as first parameter
	serviceVersion = os.Args[1]

	// load website template
	// overviewTemplate = template.Must(template.ParseFiles("./overview.html"))

	// create a new handler
	handler := HTTPHandler{}

	// service static files
	fileServer := http.FileServer(http.Dir("./static"))

	http.Handle("/", handler)
	http.Handle("/static/", http.StripPrefix("/static/", fileServer))
	fmt.Println("Serving requests on port 9000")

	http.Handle("/metrics", promhttp.Handler())
	http.ListenAndServe(":9000", nil)

	// listen and serve
	http.ListenAndServe(":9000", nil)

}
