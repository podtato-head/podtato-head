package pkg

import "errors"

var preconfiguredBindings = map[string]PodtatoComponents{
	"0.1.0": {
		BodyHats: BodyHats{Id: "01"},
		LeftArm:  LeftArm{Id: "01"},
		LeftLeg:  LeftLeg{Id: "01"},
		RightArm: RightArm{Id: "01"},
		RightLeg: RightLeg{Id: "01"},
	},
	"0.1.1": {
		BodyHats: BodyHats{Id: "02"},
		LeftArm:  LeftArm{Id: "02"},
		LeftLeg:  LeftLeg{Id: "02"},
		RightArm: RightArm{Id: "02"},
		RightLeg: RightLeg{Id: "02"},
	},
	"0.1.2": {
		BodyHats: BodyHats{Id: "03"},
		LeftArm:  LeftArm{Id: "03"},
		LeftLeg:  LeftLeg{Id: "03"},
		RightArm: RightArm{Id: "03"},
		RightLeg: RightLeg{Id: "03"},
	},
	"0.1.3": {
		BodyHats: BodyHats{Id: "04"},
		LeftArm:  LeftArm{Id: "04"},
		LeftLeg:  LeftLeg{Id: "04"},
		RightArm: RightArm{Id: "04"},
		RightLeg: RightLeg{Id: "04"},
	},
}

func GetAssembledPodtatoConfiguration(version string) (*PodtatoConfig, error) {

	if _, ok := preconfiguredBindings[version]; !ok {
		return nil, errors.New("no components found for provided version")
	}

	return &PodtatoConfig{
		ServiceVersion: version,
		Components:     preconfiguredBindings[version],
	}, nil
}
