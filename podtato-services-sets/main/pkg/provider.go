package pkg

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/gorilla/mux"

	"github.com/kelseyhightower/envconfig"
)

	var serviceMap = map[string]string{}

	var c Configuration

func ProviderHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	err := envconfig.Process("main", &c)
	fmt.Println(c)
	if err != nil {
		fmt.Errorf("Could not read environment")
	}

	serviceMap = map[string]string{
		"hats": c.HatsServiceProtocol + "://" + c.HatsServiceHost + ":" + c.HatsServicePort,
		"legs": c.LegsServiceProtocol + "://" + c.LegsServiceHost + ":" + c.LegsServicePort,
		"arms": c.ArmsServiceProtocol + "://" + c.ArmsServiceHost + ":" + c.ArmsServicePort,
	}

	callPodtatoService(w, vars["service"], vars["img"])
}

func callPodtatoService(w http.ResponseWriter, part, image string) {
	fmt.Println("Calling " + serviceMap[part] + "/images/" + image )

	if _, ok := serviceMap[part]; !ok {
		http.Error(w, "invalid part", http.StatusNotFound)
		return
	}

	resp, err := http.Get(serviceMap[part] + "/images/" + image)
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
	_, err = w.Write(body)
	if err != nil {
		log.Printf("Write failed: %v", err)
	}
}
