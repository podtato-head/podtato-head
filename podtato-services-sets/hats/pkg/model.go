package pkg

type Configuration struct {
	HatsPort            string `envconfig:"PORT" default:"9001"`
	HatVersion          string `envconfig:"VERSION" default:"v1"`
}
