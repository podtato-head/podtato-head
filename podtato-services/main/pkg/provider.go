package pkg

import (
	"context"
	"github.com/gorilla/mux"
	"log"
	"net/http"
)

import dapr "github.com/dapr/go-sdk/client"

var serviceMap = map[string]string{
	"hats":      "podtato-hats",
	"left-leg":  "podtato-left-leg",
	"left-arm":  "podtato-left-arm",
	"right-leg": "podtato-right-leg",
	"right-arm": "podtato-right-arm",
}

type ProviderDaprHandler struct {
	client dapr.Client
}

func NewProviderDaprHandler() (*ProviderDaprHandler, error) {
	client, err := dapr.NewClient()
	if err != nil {
		return nil, err
	}
	defer client.Close()
	return &ProviderDaprHandler{
		client: client,
	}, nil
}

func ProviderHandler(w http.ResponseWriter, r *http.Request, client dapr.Client) {
	vars := mux.Vars(r)
	callPodtatoService(w, vars["service"], vars["img"], client)
}

func callPodtatoService(w http.ResponseWriter, part, image string, client dapr.Client) {
	if _, ok := serviceMap[part]; !ok {
		http.Error(w, "invalid part", http.StatusNotFound)
		return
	}

	resp, err := client.InvokeMethod(context.Background(), serviceMap[part], "images/"+image, "get")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "image/svg+xml")
	w.WriteHeader(http.StatusOK)
	_, err = w.Write(resp)
	if err != nil {
		log.Printf("Write failed: %v", err)
	}
}
