package pkg

type Configuration struct {
	LegsPort            string `envconfig:"PORT" default:"9003"`
	RightLegVersion         string `envconfig:"RIGHT_VERSION" default:"v1"`
	LeftLegVersion         string `envconfig:"LEFT_VERSION" default:"v1"`
}
