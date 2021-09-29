package pkg

import (
	"github.com/gorilla/mux"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
)

type versionedHandler struct {
	staticFilePath string
	leftVersion    string
	rightVersion   string
	side           string
}

var versionBinding = map[string]string{
	"v1": "01",
	"v2": "02",
	"v3": "03",
	"v4": "04",
}

func NewVersionedHandler(leftVersion, rightVersion, staticFilePath string) versionedHandler {
	return versionedHandler{
		leftVersion:    leftVersion,
		rightVersion:   rightVersion,
		staticFilePath: staticFilePath,
	}
}

func (v versionedHandler) Handler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	s := strings.Split(vars["hat"], "-")
	side := s[0]
	var version string
	if side == "right" {
		version = versionBinding[v.rightVersion]
	} else {
		version = versionBinding[v.leftVersion]
	}
	img, err := ioutil.ReadFile(v.staticFilePath + "/" + side + "-leg-" + version + ".svg")
	if err != nil {
		log.Print("Error:", err)
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
