package metrics

import (
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/podtato-head/podtato-head/pkg/util"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
)

func init() {
	err := prometheus.Register(CallCounter)
	if err != nil {
		log.Fatal(err, "couldn't register CallCounter")
	}
	err = prometheus.Register(LatencyHistogram)
	if err != nil {
		log.Fatal(err, "couldn't register LatencyHistogram")
	}
}

var CallCounter = prometheus.NewCounterVec(prometheus.CounterOpts{
		Name: "http_requests_total",
		Help: "Count of HTTP requests by response status code.",
	},
	[]string{"status_code"},
)

var LatencyHistogram = prometheus.NewHistogramVec(prometheus.HistogramOpts{
		Name:    "http_server_request_latency_seconds",
		Help:    "Histogram of request latency in seconds",
		Buckets: []float64{.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10},
	},
	[]string{"route", "method", "status_code"},
)

func MetricsHandler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// setup to record latency and status
		start := time.Now()
		rw := util.StatusRecordingResponseWriter{ResponseWriter: w, Status: 200}
		next.ServeHTTP(&rw, r)

		// record latency and status
		duration := time.Since(start)
		statusCode := strconv.Itoa(rw.Status)
		routePath := getRoutePathTemplate(r)

		log.Printf("request: path [%s], status [%s], duration [%s]", routePath, statusCode, duration)
		LatencyHistogram.WithLabelValues(routePath, r.Method, statusCode).Observe(duration.Seconds())

		CallCounter.WithLabelValues(statusCode).Inc()
	})
}

func getRoutePathTemplate(r *http.Request) string {
	pathTemplate := "[unknown]"
	temp, _ := mux.CurrentRoute(r).GetPathTemplate()
	if temp != "" { pathTemplate = temp }
	return pathTemplate
}