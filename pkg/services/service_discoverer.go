package services

import (
	"fmt"
	"log"
	"net/url"
)

type ServiceDiscoverer interface {
	DiscoverService(name string) (*url.URL, error)
}

type staticServiceDiscoverer struct {
	staticServiceMap map[string]*url.URL
}

func NewStaticServiceDiscoverer() *staticServiceDiscoverer {
	return &staticServiceDiscoverer{
		staticServiceMap: map[string]*url.URL{
			"hats": mustParseURL("http://podtato-hats:9001"),
			"left-leg": mustParseURL("http://podtato-left-leg:9002"),
			"left-arm": mustParseURL("http://podtato-left-arm:9003"),
			"right-leg": mustParseURL("http://podtato-right-leg:9004"),
			"right-arm": mustParseURL("http://podtato-right-arm:9005"),
		},
	}
}

func (s *staticServiceDiscoverer) DiscoverService(name string) (*url.URL, error) {
	addr, found := s.staticServiceMap[name]
	if !found {
		return nil, fmt.Errorf("service [%s] not found in static map", name)
	}
	return addr, nil
}

func mustParseURL(rawURL string) *url.URL {
	out, err := url.Parse(rawURL)
	if err != nil {
		log.Fatalf("failed to parse static URL [%s]: %v", rawURL, err)
	}
	return out
}