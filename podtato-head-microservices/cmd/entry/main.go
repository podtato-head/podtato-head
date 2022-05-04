package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"

	"github.com/podtato-head/podtato-head/pkg/assets"
	"github.com/podtato-head/podtato-head/pkg/auth"
	"github.com/podtato-head/podtato-head/pkg/metrics"
	"github.com/podtato-head/podtato-head/pkg/services"
	"github.com/podtato-head/podtato-head/pkg/sessions"
	"github.com/podtato-head/podtato-head/pkg/version"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

const (
	assetsPrefix           = "/assets"
	externalServicesPrefix = "/parts"
)

func serveHTTP(w http.ResponseWriter, r *http.Request) {
	session, _ := sessions.Store.Get(r, sessions.SessionName)
	userinfo, found := session.Values["userinfo"].(string)
	if !found {
		log.Printf("did not find userinfo")
		userinfo = "{ \"name\": \"anonymous\" }"
	} else {
		log.Printf("got userinfo from session: %v", userinfo)
	}

	params := make(map[string]interface{})
	err := json.Unmarshal([]byte(userinfo), &params)
	if err != nil {
		http.Error(w, "failed to unmarshal userinfo", http.StatusInternalServerError)
		return
	}
	log.Printf("unmarshalled userinfo: %v", params)

	homeTemplate, err := template.ParseFS(assets.Assets, "html/podtato-home.html")
	if err != nil {
		log.Fatalf("failed to parse file: %v", err)
	}

	params["version"] = version.ServiceVersion()

	err = homeTemplate.Execute(w, params)
	if err != nil {
		log.Fatalf("failed to execute template: %v", err)
	}
}

func main() {
	router := mux.NewRouter()
	auth.SetupCallbackHandler(router)

	// gather and emit Prometheus metrics
	router.Use(metrics.MetricsHandler)
	router.Path("/metrics").Handler(promhttp.Handler())

	// render home page
	router.Path("/").Handler(auth.Authenticate(http.HandlerFunc(serveHTTP)))

	// serve CSS and images
	router.PathPrefix(assetsPrefix).Handler(auth.Authenticate(http.StripPrefix(assetsPrefix, http.FileServer(http.FS(assets.Assets)))))

	// call other services
	router.Path(fmt.Sprintf("%s/{partName}/{imagePath}", externalServicesPrefix)).
		Handler(auth.Authenticate(http.HandlerFunc(services.HandleExternalService)))

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
