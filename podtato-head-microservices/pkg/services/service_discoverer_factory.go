package services

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/go-yaml/yaml"
)

var (
	configFilePath string
)

const (
	configFilePathEnvVarName      = "SERVICES_CONFIG_FILE_PATH"
	configFilePathDefaultBaseName = "servicesConfig.yaml"
)

func discoverConfigFile() (configFilePath string, found bool) {
	found = false
	configFilePath = os.Getenv(configFilePathEnvVarName)
	if len(configFilePath) == 0 {
		pwd, err := os.Getwd()
		if err != nil {
			log.Printf("WARNING: failed to determine current working dir: %v", err)
		}
		configFilePath = fmt.Sprintf("%s/%s", pwd, configFilePathDefaultBaseName)
	}
	if _, err := os.Stat(configFilePath); err != nil {
		log.Printf("INFO: did not find service discovery config file at path %s", configFilePath)
		found = false
	} else {
		log.Printf("INFO: found service discovery config file at path %s", configFilePath)
		found = true
	}
	return configFilePath, found
}

func ProvideServiceDiscoverer() (ServiceMap, error) {
	if _, found := discoverConfigFile(); found {
		return NewConfigFileServiceDiscoverer()
	}
	return NewStaticServiceDiscoverer()
}

// TODO: should this dynamically read the file, or just once on startup?
type configFileServiceDiscoverer struct {
	serviceMap
}

var _ ServiceMap = &configFileServiceDiscoverer{}

func NewConfigFileServiceDiscoverer() (*configFileServiceDiscoverer, error) {
	if len(configFilePath) == 0 {
		var ok bool
		if configFilePath, ok = discoverConfigFile(); !ok {
			log.Panicf("FAIL: could not find config file")
		}
	}
	b, err := ioutil.ReadFile(configFilePath)
	if err != nil {
		log.Fatalf("FAIL: failed to read config file from path %s: %v", configFilePath, err)
	}
	config := make(map[string]string)
	err = yaml.Unmarshal(b, config)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal YAML file %s: %w", configFilePath, err)
	}
	serviceMap, err := NewServiceMap(config)
	if err != nil {
		return nil, fmt.Errorf("failed to convert strings to URLs for map: %w", err)
	}
	return &configFileServiceDiscoverer{serviceMap}, nil
}

type staticServiceDiscoverer struct {
	serviceMap
}

var _ ServiceMap = &staticServiceDiscoverer{}

func NewStaticServiceDiscoverer() (*staticServiceDiscoverer, error) {
	serviceMap, err := NewServiceMap(map[string]string{
		"hat":       "http://podtato-head-hat:9001",
		"left-leg":  "http://podtato-head-left-leg:9002",
		"left-arm":  "http://podtato-head-left-arm:9003",
		"right-leg": "http://podtato-head-right-leg:9004",
		"right-arm": "http://podtato-head-right-arm:9005",
	})
	if err != nil {
		return nil, fmt.Errorf("failed to convert strings to URLs for map: %w", err)
	}
	return &staticServiceDiscoverer{serviceMap}, nil
}
