package services

import (
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/jarcoal/httpmock"

	"github.com/gorilla/mux"
)

var (
	mockURL  = "http://podtato-head-hat:9001/images/hat.svg"
	filePath = "testdata/hat-01.svg"
)

func TestMain(m *testing.M) {
	httpmock.Activate()
	defer httpmock.DeactivateAndReset()

	httpmock.RegisterResponder("GET", mockURL,
		func(r *http.Request) (*http.Response, error) {
			resp := httpmock.NewBytesResponse(200, httpmock.File(filePath).Bytes())
			resp.Header.Add("Content-Type", "image/svg+xml")
			return resp, nil
		},
	)

	os.Exit(m.Run())
}

func TestServiceHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/parts/hat/hat.svg", nil)
	if err != nil {
		t.Fatal(err)
	}
	req = mux.SetURLVars(req, map[string]string{
		"partName":  "hat",
		"imagePath": "hat.svg",
	})

	rr := httptest.NewRecorder()

	// TODO: inject alternate service discoverer?
	// TODO: mock destination of service (https://pkg.go.dev/github.com/jarcoal/httpmock)
	handler := http.HandlerFunc(HandleExternalService)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned unexpected status code: got %v, expected %v", status, http.StatusOK)
	}
}
