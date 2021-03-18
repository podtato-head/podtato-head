package main

import (
	"fmt"
	"strconv"
	"time"

	"github.com/gorilla/mux"

	"html/template"
	"log"
	"net/http"
	"os"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

//
var serviceVersion string
var podtatoId string

// HTML page template
var overviewTemplate *template.Template

// create a new counter vector
var getCallCounter = prometheus.NewCounterVec(
	prometheus.CounterOpts{
		Name: "http_requests_total", // metric name
		Help: "Number of get requests.",
	},
	[]string{"status"}, // labels
)

var buckets = []float64{.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10}

var responseTimeHistogram = prometheus.NewHistogramVec(prometheus.HistogramOpts{
	Name:    "http_server_request_duration_seconds",
	Help:    "Histogram of response time for handler in seconds",
	Buckets: buckets,
}, []string{"route", "method", "status_code"})

type Overview struct {
	Version string
	PartId  string
}

// create a handler struct
type HTTPHandler struct{}

type statusRecorder struct {
	http.ResponseWriter
	statusCode int
}

func (rec *statusRecorder) WriteHeader(statusCode int) {
	rec.statusCode = statusCode
	rec.ResponseWriter.WriteHeader(statusCode)
}

func getRoutePattern(r *http.Request) string {
	reqContext := mux.CurrentRoute(r)
	if pattern, _ := reqContext.GetPathTemplate(); pattern != "" {
		return pattern
	}

	fmt.Println(reqContext.GetPathRegexp())

	return "undefined"
}

// implement `ServeHTTP` method on `HttpHandler` struct
func (h HTTPHandler) ServeHTTP(res http.ResponseWriter, req *http.Request) {
	var status string
	defer func() {
		// increment the counter on defer func
		getCallCounter.WithLabelValues(status).Inc()
	}()

	overviewData := Overview{
		Version: serviceVersion,
		PartId:  podtatoId,
	}
	overviewTemplate = template.Must(template.ParseFiles("./podtato-new.html"))
	err := overviewTemplate.Execute(res, overviewData)

	// Slow build
	if serviceVersion == "0.1.2" {
		time.Sleep(2 * time.Second)
	}

	if err != nil {
		status = "error"
	}
	status = "success"
}

func prometheusMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rec := statusRecorder{w, 200}

		next.ServeHTTP(&rec, r)

		duration := time.Since(start)
		statusCode := strconv.Itoa(rec.statusCode)
		route := getRoutePattern(r)
		fmt.Println(duration.Seconds())
		responseTimeHistogram.WithLabelValues(route, r.Method, statusCode).Observe(duration.Seconds())
	})
}

func init() {
	prometheus.Register(getCallCounter)
	prometheus.Register(responseTimeHistogram)
}

func main() {
	// expecting version as first parameter
	serviceVersion = os.Args[1]

	switch serviceVersion {
	case "0.1.0":
		podtatoId = "01"
	case "0.1.1":
		podtatoId = "02"
	case "0.1.2":
		podtatoId = "03"
	case "0.1.3":
		podtatoId = "04"
	}

	// load website template
	//overviewTemplate = template.Must(template.ParseFiles("./podtato-new.html"))

	// create a new handler
	handler := HTTPHandler{}

	router := mux.NewRouter()
	router.Use(prometheusMiddleware)

	router.Path("/").Handler(handler)
	router.Path("/")

	staticDir := "/static/"

	// Serving static files
	router.
		PathPrefix(staticDir).
		Handler(http.StripPrefix(staticDir, http.FileServer(http.Dir("."+staticDir))))

	router.Path("/metrics").Handler(promhttp.Handler())

	fmt.Println("Serving requests on port 9000")
	err := http.ListenAndServe(":9000", router)
	log.Fatal(err)
}
