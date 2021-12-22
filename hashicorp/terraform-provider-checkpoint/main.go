package main

import (
	"github.com/CheckPointSW/terraform-provider-checkpoint/checkpoint"
	"github.com/hashicorp/terraform-plugin-sdk/plugin"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: checkpoint.Provider,
	})
}
