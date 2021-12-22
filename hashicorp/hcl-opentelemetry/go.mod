module github.com/hashicorp/hcl-opentelemetry

go 1.13

require (
	github.com/mitchellh/reflectwalk v1.0.1
	go.opentelemetry.io/contrib/exporters/metric/dogstatsd v0.6.1
	go.opentelemetry.io/otel v0.6.0
	go.opentelemetry.io/otel/exporters/metric/prometheus v0.6.0
)
