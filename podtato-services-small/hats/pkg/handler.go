package pkg

import (
	"embed"
	"log"
	"net/http"
)

type versionedHandler struct {
	staticFilePath string
	version        string
	embedFS        embed.FS
}

var versionBinding = map[string]string{
	"v1": "01",
	"v2": "02",
	"v3": "03",
	"v4": "03",
}

func NewVersionedHandler(version, staticFilePath string, embedFS embed.FS) versionedHandler {
	return versionedHandler{
		version:        version,
		staticFilePath: staticFilePath,
		embedFS:        embedFS,
	}
}

func (v versionedHandler) Handler(w http.ResponseWriter, r *http.Request) {
	img, err := v.embedFS.ReadFile(v.staticFilePath + "hat-" + versionBinding[v.version] + ".svg")
	if err != nil {
		log.Print("Error: ", err)
		w.WriteHeader(500)
		return
	}
	w.Header().Set("Content-Type", "image/svg+xml")
	w.WriteHeader(200)
	_, err = w.Write(img)
	if err != nil {
		log.Printf("Write failed: %v", err)
	}
}
