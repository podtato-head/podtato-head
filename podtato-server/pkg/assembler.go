package pkg

import "errors"

var preconfiguredBindings = map[string] string{
	"0.1.0": "01",
	"0.1.1": "02",
	"0.1.2": "03",
	"0.1.3": "04",
}

func GetAssembledPodtatoConfiguration(version string) (*PodtatoConfig,error){

	if _, ok := preconfiguredBindings[version]; !ok {
		return nil, errors.New("no components found for provided version")
	}

	return &PodtatoConfig{
		ServiceVersion: version,
		ComponentID: preconfiguredBindings[version],
	},nil
}