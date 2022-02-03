package handlers

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gorilla/mux"
)

func TestPartHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/images/hat.svg", nil)
	if err != nil {
		t.Fatal(err)
	}
	req = mux.SetURLVars(req, map[string]string{"imageName": "hat"})

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(PartHandler)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned unexpected status code: got %v, expected %v", status, http.StatusOK)
	}
}
