# hcl-opentelemetry
This library provides an `hclotel` package to load HCL configuration and initialize OpenTelemetry sinks to use for metrics reporting.

## Sinks
* Stdout
* Dogstatsd
* Prometheus

## Quick Start
<details>
<summary>Full example loading configuration and reporting metrics to stdout</summary>
<p>

```go
package main

import (
	"context"

	"github.com/hashicorp/hcl"
	"github.com/hashicorp/hcl-opentelemetry"
	"github.com/mitchellh/mapstructure"
	"go.opentelemetry.io/otel/api/kv"
	"go.opentelemetry.io/otel/api/metric"
)

var data = `
telemetry {
	stdout {}
}
`

type Config struct {
	Telemetry *hclotel.TelemetryConfig `mapstructure:"telemetry"`
}

func main() {
	var raw map[string]interface{}
	err := hcl.Decode(&raw, data)
	if err != nil {
		panic(err)
	}

	var config Config
	d, err := mapstructure.NewDecoder(&mapstructure.DecoderConfig{
		DecodeHook: mapstructure.ComposeDecodeHookFunc(
			hclotel.HookWeakDecodeFromSlice,
			mapstructure.StringToTimeDurationHookFunc(),
		),
		Result:      &config,
		ErrorUnused: true,
	})
	if err := d.Decode(raw); err != nil {
		panic(err)
	}
	config.Telemetry.Finalize()

	tel, err := hclotel.Init(config.Telemetry)
	if err != nil {
		panic(err)
	}
	defer tel.Stop()

	key := kv.Key("key")
	meter := hclotel.GlobalMeter()

	// Example counter
	counter := metric.Must(meter).NewInt64Counter("foo.bar")
	labels := []kv.KeyValue{key.String("value")}

	ctx := context.Background()
	counter.Add(ctx, 1, labels...)
}
```
</p>
</details>

## Configuration
The library supports configuration files written in the [HashiCorp Configuration Language](https://github.com/hashicorp/hcl), and by proxy this means it is also JSON compatible. Only one sink can be used at a given time.

```hcl
telemetry {
  metrics_prefix = ""

  stdout {
    period = "60s"
    pretty_print = false
    do_not_print_time = false
  }

  dogstatsd {
    // address describes the destination for exporting dogstatsd data.
    // e.g., udp://host:port tcp://host:port unix:///socket/path
    address = "udp://127.0.0.1:8125"
    period = "60s"
  }

  prometheus {
    cache_period = "60s"
    port = 8888
  }
}
```
