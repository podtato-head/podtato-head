package util

import (
	"net/http"
)

type StatusRecordingResponseWriter struct {
	http.ResponseWriter
	Status int
}

func (w *StatusRecordingResponseWriter) WriteHeader(status int) {
	w.Status = status
	w.ResponseWriter.WriteHeader(status)
}