## Info

podtato-head consists of an entry point container ("entry") and 5 parts
containers. Requests arrive at the entry point, which coordinates responses from
the backing services.

The backing services are located using a "ServiceDiscoverer" type defined in
`pkg/services`. The default ServiceDiscoverer uses hard-coded URLs; but a
config-file-based ServiceDiscoverer can be used instead by setting a file path
in env var "SERVICES_CONFIG_FILE_PATH" pointing to a map of short service names
like `hat` to HTTP URLs. See [testdata/servicesConfig.yaml](./podtato-head-microservices/pkg/services/testdata/servicesConfig.yaml) for an example.

In the Helm chart the ports for the backing services are coordinated between the
config file in a config map and the services themselves in Service manifests.
See [delivery/chart/templates/configmap-discovery.yaml](../delivery/chart/templates/configmap-discovery.yaml).
