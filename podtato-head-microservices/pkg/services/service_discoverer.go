package services

import (
	"fmt"
	"log"
	"net/url"
	"os"
)

type ServiceDiscoverer interface {
	DiscoverService(name string) (*url.URL, error)
}

type staticServiceDiscoverer struct {
	staticServiceMap map[string]*url.URL
}

func NewStaticServiceDiscoverer() *staticServiceDiscoverer {
	hatHost, found := os.LookupEnv("HAT_HOST")
	if !found {
		hatHost = "podtato-head-hat"
	}
	leftLegHost, found := os.LookupEnv("LEFT_LEG_HOST")
	if !found {
		leftLegHost = "podtato-head-left-leg"
	}

	leftArmHost, found := os.LookupEnv("LEFT_ARM_HOST")
	if !found {
		leftArmHost = "podtato-head-left-arm"
	}
	rightLegHost, found := os.LookupEnv("RIGHT_LEG_HOST")
	if !found {
		rightLegHost = "podtato-head-right-leg"
	}
	rightArmHost, found := os.LookupEnv("RIGHT_ARM_HOST")
	if !found {
		rightArmHost = "podtato-head-right-arm"
	}
	return &staticServiceDiscoverer{
		staticServiceMap: map[string]*url.URL{
			"hat":       mustParseURL(fmt.Sprintf("http://%s:9001", hatHost)),
			"left-leg":  mustParseURL(fmt.Sprintf("http://%s:9002", leftLegHost)),
			"left-arm":  mustParseURL(fmt.Sprintf("http://%s:9003", leftArmHost)),
			"right-leg": mustParseURL(fmt.Sprintf("http://%s:9004", rightLegHost)),
			"right-arm": mustParseURL(fmt.Sprintf("http://%s:9005", rightArmHost)),
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
