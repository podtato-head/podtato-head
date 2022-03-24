package services

import (
	"fmt"
	"os"
	"testing"
)

func TestStaticServiceDiscoverer(t *testing.T) {
	discoverer, err := NewStaticServiceDiscoverer()
	if err != nil {
		t.Fatalf("failed to construct static service discoverer: %v", err)
	}

	testServiceName := "test"
	testServiceAddress := "http://podtato-head-test:10000"
	err = discoverer.AddOrUpdateService(testServiceName, testServiceAddress)
	if err != nil {
		t.Fatalf("failed to add service %s address %s to service discoverer: %v", testServiceName, testServiceAddress, err)
	}

	addr, err := discoverer.GetServiceAddress(testServiceName)
	t.Logf("got service address %s", addr)
	if err != nil {
		t.Fatalf("failed to get address for service %s: %v", testServiceName, err)
	}
	if addr.String() != testServiceAddress {
		t.Fatalf("got unexpected addr %s, expected %s", addr, testServiceAddress)
	}
}

func TestConfigFileServiceDiscoverer(t *testing.T) {
	wd, err := os.Getwd()
	if err != nil {
		t.Fatalf("failed to find current working dir: %v", err)
	}
	os.Setenv(configFilePathEnvVarName, fmt.Sprintf("%s/testdata/%s", wd, configFilePathDefaultBaseName))
	defer os.Unsetenv(configFilePathEnvVarName)
	discoverer, err := NewConfigFileServiceDiscoverer()
	if err != nil {
		t.Fatalf("failed to construct config-file service discoverer: %v", err)
	}

	// keep in sync with testdata/servicesConfig.yaml
	testServiceName := "hat"
	testServiceAddress := "http://podtato-head-hat:10001"

	addr, err := discoverer.GetServiceAddress(testServiceName)

	if err != nil {
		t.Fatalf("failed to get address for service %s: %v", testServiceName, err)
	}
	if addr.String() != testServiceAddress {
		t.Fatalf("got unexpected addr %s, expected %s", addr, testServiceAddress)
	}
}

func TestInjectedServiceDiscoverer(t *testing.T) {
	discoverer, err := ProvideServiceDiscoverer()
	if err != nil {
		t.Fatalf("failed to construct config-file service discoverer: %v", err)
	}

	// keep in sync with testdata/servicesConfig.yaml
	testServiceName := "hat"
	testServiceAddress := "http://podtato-head-hat:9001"

	addr, err := discoverer.GetServiceAddress(testServiceName)
	if err != nil {
		t.Fatalf("failed to get address for service %s: %v", testServiceName, err)
	}
	if addr.String() != testServiceAddress {
		t.Fatalf("got unexpected addr %s, expected %s", addr, testServiceAddress)
	}
}
