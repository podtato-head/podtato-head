package pkg

import (
	"io/ioutil"
	"log"
	"net/http"
)

type versionedHandler struct {
	staticFilePath string
	version        string
}

var versionBinding = map[string]string{
	"v1": "01",
	"v2": "02",
	"v3": "03",
	"v4": "03",
}

func NewVersionedHandler(version, staticFilePath string) versionedHandler {
	return versionedHandler{
		version:        version,
		staticFilePath: staticFilePath,
	}
}

func (v versionedHandler) Handler(w http.ResponseWriter, r *http.Request) {
	img, err := ioutil.ReadFile(v.staticFilePath + "hat-" + versionBinding[v.version] + ".svg")
	if err != nil {
		log.Print("Error: ", err)
		w.WriteHeader(500)
		return
	}
	w.Header().Set("Content-Type", "image/svg+xml")
	w.WriteHeader(200)
	w.Write(img)
}
