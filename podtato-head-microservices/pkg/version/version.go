package version

import (
	"os"
)

const (
	defaultServiceVersion string = "v0.1.0"
	defaultPartNumber     string = "01"
)

func ServiceVersion() string {
	dynamicVersion, found := os.LookupEnv("PODTATO_VERSION")
	if !found || dynamicVersion == "" {
		return defaultServiceVersion
	}
	return dynamicVersion
}

func PartNumber() string {
	dynamicPartNumber, found := os.LookupEnv("PODTATO_PART_NUMBER")
	if !found || dynamicPartNumber == "" {
		return defaultPartNumber
	}
	return dynamicPartNumber
}
