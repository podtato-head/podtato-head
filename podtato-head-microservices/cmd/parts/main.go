package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/podtato-head/podtato-head/pkg/handlers"
	"github.com/podtato-head/podtato-head/pkg/metrics"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	router := mux.NewRouter()

	// gather and emit Prometheus metrics
	router.Use(metrics.MetricsHandler)
	router.Path("/metrics").Handler(promhttp.Handler())

	// serve current image
	router.Path("/images/{imageName}").HandlerFunc(handlers.PartHandler)

	port, found := os.LookupEnv("PODTATO_PORT")
	if !found || port == "" {
		port = "9000"
	}
	log.Printf("going to serve on port %s", port)
	if err := http.ListenAndServe(fmt.Sprintf(":%s", port), router); err != nil {
		log.Fatal(err)
	}
	log.Printf("exiting gracefully")
}