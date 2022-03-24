package services

import (
	"testing"
)

func TestServiceMap(t *testing.T) {
	testMap, err := NewServiceMap(map[string]string{
		"hat":       "http://podtato-head-hat:9001",
		"left-leg":  "http://podtato-head-left-leg:9002",
		"left-arm":  "http://podtato-head-left-arm:9003",
		"right-leg": "http://podtato-head-right-leg:9004",
		"right-arm": "http://podtato-head-right-arm:9005",
	})
	if err != nil {
		t.Fatalf("failed to create service map: %v", err)
	}

	testServiceName := "test"
	testServiceAddress := "http://podtato-head-test:10000"
	err = testMap.AddOrUpdateService(testServiceName, testServiceAddress)
	if err != nil {
		t.Fatalf("failed to add service %s address %s to service map: %v", testServiceName, testServiceAddress, err)
	}

	addr, err := testMap.GetServiceAddress(testServiceName)
	if err != nil {
		t.Fatalf("failed to get address for service %s: %v", testServiceName, err)
	}
	if addr.String() != testServiceAddress {
		t.Fatalf("got unexpected addr %s, expected %s", addr, testServiceAddress)
	}
}
