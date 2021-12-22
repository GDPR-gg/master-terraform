package hclotel

import (
	"log"
	"sync"

	"go.opentelemetry.io/otel/api/global"
	"go.opentelemetry.io/otel/api/metric"
)

var (
	// globalMeterName is the name of the global meter
	globalMeterName = ""

	meterNameMux sync.Mutex
)

// Telemetry manages the telemetry sinks and abstracts the caller from the
// which provider is configured.
type Telemetry struct {
	controller Controller

	Metric metric.Provider
	Meter  metric.Meter
}

// Controller is an abstraction to safely stop processing and exporting metrics
// across various exporters.
type Controller interface {
	Stop()
}

// GlobalMeter is a wrapper to fetch the global meter
func GlobalMeter() metric.Meter {
	return global.Meter(GlobalMeterName())
}

// GlobalMeterName returns the name of the global meter
func GlobalMeterName() string {
	meterNameMux.Lock()
	defer meterNameMux.Unlock()
	return globalMeterName
}

// Init initializes metrics reporting. If no sink is configured, the no-op
// provider is used.
func Init(c *TelemetryConfig) (*Telemetry, error) {
	var meterName string
	if c.MetricsPrefix != nil && len(*c.MetricsPrefix) > 0 {
		meterNameMux.Lock()
		globalMeterName = *c.MetricsPrefix
		meterName = *c.MetricsPrefix
		meterNameMux.Unlock()
	}

	// If multiple providers are configured, the last provider listed below
	// with be used. We're not requiring only one provider to be configured
	// just yet to allow flexibility later when tracing may be supported.
	var provider metric.Provider
	var ctrl Controller
	var err error
	switch {
	case c.Stdout != nil:
		provider, ctrl, err = NewStdout(c.Stdout)

	case c.DogStatsD != nil:
		provider, ctrl, err = NewDogStatsD(c.DogStatsD)

	case c.Prometheus != nil:
		provider, ctrl, err = NewPrometheus(c.Prometheus)

	default:
		log.Printf("[DEBUG] (telemetry) no metric sink configured, using no-op provider")
		provider = &metric.NoopProvider{}
	}
	if err != nil {
		return nil, err
	}

	global.SetMeterProvider(provider)

	return &Telemetry{
		controller: ctrl,
		Metric:     provider,
		Meter:      global.Meter(meterName),
	}, nil
}

// Stop propagates stop to the controller and waits for the background
// go routine and exports metrics one last time before returning.
func (t *Telemetry) Stop() {
	if t.controller != nil {
		t.controller.Stop()
	}
}
