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
	"0.1.0": "01",
	"0.1.1": "02",
	"0.1.2": "03",
	"0.1.3": "04",
	"0.1.4": "05",
}

func NewVersionedHandler(version, staticFilePath string) versionedHandler {
	return versionedHandler{
		version:        version,
		staticFilePath: staticFilePath,
	}
}

func (v versionedHandler) Handler(w http.ResponseWriter, r *http.Request) {
	img, err := ioutil.ReadFile(v.staticFilePath + "right-leg-" + versionBinding[v.version] + ".svg")
	if err != nil {
		log.Print("Error:", err)
		w.WriteHeader(500)
		return
	}
	w.Header().Set("Content-Type", "image/svg+xml")
	w.WriteHeader(200)
	w.Write(img)
}
