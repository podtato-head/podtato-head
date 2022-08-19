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
	session, err := sessions.Store.Get(r, sessions.SessionName)
	if err != nil {
		log.Printf("ERROR: failed to create or restore session: %s", err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	userinfo, found := session.Values["userinfo"].(string)
	if !found {
		log.Printf("WARN: did not find userinfo")
		userinfo = "{ \"name\": \"anonymous\" }"
	} else {
		log.Printf("got userinfo from session: %v", userinfo)
	}

	params := make(map[string]interface{})
	err = json.Unmarshal([]byte(userinfo), &params)
	if err != nil {
		log.Printf("ERROR: failed to unmarshal userinfo JSON: %s", err.Error())
		http.Error(w, "failed to unmarshal userinfo", http.StatusInternalServerError)
		return
	}
	log.Printf("INFO: unmarshalled userinfo: %v", params)

	homeTemplate, err := template.ParseFS(assets.Assets, "html/podtato-home.html")
	if err != nil {
		log.Printf("failed to parse file: %v", err)
		http.Error(w, "failed to parse home page template", http.StatusInternalServerError)
		return
	}

	params["version"] = version.ServiceVersion()

	err = homeTemplate.Execute(w, params)
	if err != nil {
		log.Printf("failed to execute template: %v", err)
		http.Error(w, "failed to render home page template", http.StatusInternalServerError)
		return
	}
}

func main() {
	router := mux.NewRouter()

	// gather and emit Prometheus metrics
	router.Use(metrics.MetricsHandler)
	router.Path("/metrics").Handler(promhttp.Handler())

	auth.SetupCallbackHandler(router)

	router.Path("/").Handler(auth.Authenticate(http.HandlerFunc(serveHTTP)))

	// assets: CSS and images
	router.PathPrefix(assetsPrefix).Handler(auth.Authenticate(http.StripPrefix(assetsPrefix, http.FileServer(http.FS(assets.Assets)))))

	// pass through to other services
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
