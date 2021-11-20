package pkg

type Configuration struct {
	HatsServiceProtocol string `envconfig:"HATS_PROTO" default:"http"`
	HatsServiceHost     string `envconfig:"HATS_HOST" default:"podtato-hats"`
	HatsServicePort     string `envconfig:"HATS_PORT" default:"9001"`
	ArmsServiceProtocol string `envconfig:"ARMS_PROTO" default:"http"`
	ArmsServiceHost     string `envconfig:"ARMS_HOST" default:"podtato-arms"`
	ArmsServicePort     string `envconfig:"ARMS_PORT" default:"9002"`
	LegsServiceProtocol string `envconfig:"LEGS_PROTO" default:"http"`
	LegsServiceHost     string `envconfig:"LEGS_HOST" default:"podtato-legs"`
	LegsServicePort     string `envconfig:"LEGS_PORT" default:"9003"`
	MainPort            string `envconfig:"PORT" default:"9000"`
	MainVersion         string `envconfig:"VERSION" default:"v1"`
}
