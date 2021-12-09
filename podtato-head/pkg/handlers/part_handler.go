package handlers

import (
	"fmt"
	"io/fs"
	"log"
	"net/http"
	"strings"

	"github.com/gorilla/mux"
	"github.com/podtato-head/podtato-head/pkg/assets"
	"github.com/podtato-head/podtato-head/pkg/version"
)

func PartHandler(w http.ResponseWriter, r *http.Request) {
	imageName, found := mux.Vars(r)["imageName"]
	if !found {
		// shouldn't happen...
		http.Error(w, fmt.Sprintf("image name %s not found in URL", imageName), http.StatusNotFound)
		return
	}

	imageName = strings.TrimSuffix(imageName, ".svg")
	log.Printf("using imageName %s", imageName)

	desiredPartNumber := version.PartNumber()
	imagePath := fmt.Sprintf("images/%s/%s-%s.svg", imageName, imageName, desiredPartNumber)

	log.Printf("returning file %s", imagePath)
	image, err := fs.ReadFile(assets.Assets, imagePath)
	if err != nil {
		log.Printf("failed to read file %s: %v", imagePath, err)
		http.Error(w, fmt.Sprintf("failed to read file %s", imagePath), http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "image/svg+xml")
	w.WriteHeader(200)
	_, err = w.Write(image)
	if err != nil {
		log.Printf("failed to write response: %v", err)
	}
}
