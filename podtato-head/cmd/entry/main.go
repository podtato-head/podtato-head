package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"

	"github.com/podtato-head/podtato-head/pkg/assets"
	"github.com/podtato-head/podtato-head/pkg/metrics"
	"github.com/podtato-head/podtato-head/pkg/services"
	"github.com/podtato-head/podtato-head/pkg/version"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

const (
	assetsPrefix = "/assets"
	externalServicesPrefix = "/parts"
)

func serveHTTP(w http.ResponseWriter, r *http.Request) {
	homeTemplate, err := template.ParseFS(assets.Assets, "html/podtato-home.html")
	if err != nil {
		log.Fatalf("failed to parse file: %v", err)
	}

	err = homeTemplate.Execute(w, version.ServiceVersion())
	if err != nil {
		log.Fatalf("failed to execute template: %v", err)
	}
}

func main() {
	router := mux.NewRouter()

	// gather and emit Prometheus metrics
	router.Use(metrics.MetricsHandler)
	router.Path("/metrics").Handler(promhttp.Handler())

	// render home page
	router.Path("/").HandlerFunc(serveHTTP)

	// serve CSS and images
	router.PathPrefix(assetsPrefix).
		Handler(http.StripPrefix(assetsPrefix, http.FileServer(http.FS(assets.Assets))))

	// call other services
	router.Path(fmt.Sprintf("%s/{partName}/{imagePath}", externalServicesPrefix)).
		HandlerFunc(services.HandleExternalService)

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
