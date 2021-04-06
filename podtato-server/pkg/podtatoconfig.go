package pkg

type BodyHats struct {
	Id string
}
type LeftArm struct {
	Id string
}
type LeftLeg struct {
	Id string
}
type RightArm struct {
	Id string
}
type RightLeg struct {
	Id string
}
type PodtatoComponents struct {
	BodyHats BodyHats
	LeftArm LeftArm
	LeftLeg LeftLeg
	RightArm RightArm
	RightLeg RightLeg
}

//PodtatoConfig contains parameters for rendering the components
type PodtatoConfig struct {
	Components PodtatoComponents
	ServiceVersion string
}