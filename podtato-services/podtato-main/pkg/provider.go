package pkg

import (
	"github.com/gorilla/mux"
	"io/ioutil"
	"net/http"
)

var serviceMap = map[string]string{
	"hats":      "podtato-hats:9001",
	"left-leg":  "podtato-left-leg:9002",
	"left-arm":  "podtato-left-arm:9003",
	"right-leg": "podtato-right-leg:9004",
	"right-arm": "podtato-right-arm:9005",
}

func ProviderHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	callPodtatoService(w, vars["service"], vars["img"])
}

func callPodtatoService(w http.ResponseWriter, part, image string) {
	if _, ok := serviceMap[part]; !ok {
		http.Error(w, "invalid part", http.StatusNotFound)
		return
	}

	resp, err := http.Get("http://" + serviceMap[part] + "/images/" + image)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "image/svg+xml")
	w.WriteHeader(resp.StatusCode)
	w.Write(body)
}
