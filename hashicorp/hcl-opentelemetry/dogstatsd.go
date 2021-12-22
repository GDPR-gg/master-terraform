package hclotel

import (
	"fmt"
	"log"

	"go.opentelemetry.io/contrib/exporters/metric/dogstatsd"
	"go.opentelemetry.io/otel/api/metric"
	"go.opentelemetry.io/otel/sdk/metric/controller/push"
)

// NewDogStatsD sets up a dogstatsd exporter.
func NewDogStatsD(c *DogStatsDConfig) (metric.Provider, Controller, error) {
	log.Printf("[DEBUG] (telemetry) configuring dogstatsd sink")

	if c == nil || c.Address == nil {
		return nil, nil, fmt.Errorf("address is required for dogstatsd exporter")
	}

	cfg := dogstatsd.Config{URL: *c.Address}
	controller, err := dogstatsd.NewExportPipeline(cfg, push.WithPeriod(*c.Period))
	if err != nil {
		return nil, nil, fmt.Errorf("failed to initialize dogstatsd exporter: %s", err)
	}

	log.Printf("[DEBUG] (telemetry) dogstatsd initialized, reporting to %s", *c.Address)
	return controller.Provider(), controller, nil
}
