package hclotel_test

import (
	"context"

	"github.com/hashicorp/hcl-opentelemetry"
	"go.opentelemetry.io/otel/api/kv"
	"go.opentelemetry.io/otel/api/metric"
)

func ExampleInitStdout() {
	config := hclotel.TelemetryConfig{
		Stdout: &hclotel.StdoutConfig{
			PrettyPrint:    hclotel.Bool(true),
			DoNotPrintTime: hclotel.Bool(true),
		},
	}
	config.Finalize()

	tel, err := hclotel.Init(&config)
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

	// Output:
	// {
	// 	"updates": [
	// 		{
	// 			"name": "foo.bar{key=value}",
	// 			"sum": 1
	// 		}
	// 	]
	// }
}
