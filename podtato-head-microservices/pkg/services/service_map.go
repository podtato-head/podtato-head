package services

import (
	"fmt"
	"log"
	"net/url"
)

type ServiceMap interface {
	AddOrUpdateService(serviceName string, url string) error
	GetServiceAddress(serviceName string) (*url.URL, error)
}

var _ ServiceMap = &serviceMap{}

type serviceMap struct {
	internalMap map[string]*url.URL
}

func NewServiceMap(initial map[string]string) (serviceMap, error) {
	newMap := serviceMap{internalMap: make(map[string]*url.URL)}
	for k, v := range initial {
		newMap.internalMap[k] = mustParseURL(v)
	}
	return newMap, nil
}

func (serviceMap *serviceMap) AddOrUpdateService(serviceName string, url string) error {
	serviceMap.internalMap[serviceName] = mustParseURL(url)
	return nil
}

func (serviceMap *serviceMap) GetServiceAddress(serviceName string) (*url.URL, error) {
	url, ok := serviceMap.internalMap[serviceName]
	if !ok {
		return nil, fmt.Errorf("FAIL: failed to resolve service name %s in service map", serviceName)
	}
	return url, nil
}

func mustParseURL(rawURL string) *url.URL {
	out, err := url.Parse(rawURL)
	if err != nil {
		log.Fatalf("failed to parse static URL [%s]: %v", rawURL, err)
	}
	return out
}
