package main

import (
	"embed"
	"fmt"
	"github.com/cncf/podtato-head/podtato-services-sets/legs/pkg"
	"github.com/kelseyhightower/envconfig"
	"strconv"
	"time"

	"github.com/gorilla/mux"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"log"
	"net/http"
)

//go:embed static/*

var static embed.FS

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
	err := prometheus.Register(getCallCounter)
	if err != nil {
		log.Fatal(err, "couldn't register CallCounter")
	}
	err = prometheus.Register(responseTimeHistogram)
	if err != nil {
		log.Fatal(err, "couldn't register responseTimeHistogram")
	}
}

func main() {
	var c pkg.Configuration
	err := envconfig.Process("legs", &c)
	if err != nil {
		log.Fatal(err, "Could not read environment")
	}

	router := mux.NewRouter()
	router.Use(prometheusMiddleware)

	staticDir := "static/images"
	versionedHandler := pkg.NewVersionedHandler(c.LeftLegVersion, c.RightLegVersion, staticDir, static)

	// Serving image
	router.Path("/images/{hat}").HandlerFunc(versionedHandler.Handler)

	router.Path("/metrics").Handler(promhttp.Handler())

	fmt.Println("Serving requests on port " + c.LegsPort)
	err = http.ListenAndServe(":" + c.LegsPort, router)
	log.Fatal(err)
}
