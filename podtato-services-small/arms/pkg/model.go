package pkg

type Configuration struct {
	ArmsPort            string `envconfig:"PORT" default:"9002"`
	RightArmVersion         string `envconfig:"RIGHT_VERSION" default:"v1"`
	LeftArmVersion         string `envconfig:"LEFT_VERSION" default:"v1"`
}
