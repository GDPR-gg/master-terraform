---
layout: "dome9"
page_title: "Provider: Check Point CloudGuard Dome9"
sidebar_current: "docs-dome9-index"
description: |-
   The Check Point CloudGuard Dome9 provider is used to interact with Dome9 security posture platform, to onboard cloud accounts and configure compliance policies. To use this  provider, you must create Dome9 API credentials.
---

# Check Point CloudGuard Dome9 Provider

The Check Point CloudGuard Dome9 provider is used to interact with [Dome9](https://www.dome9.com) security posture platform, to onboard cloud accounts and configure compliance policies. To use this  provider, you must create Dome9 API credentials.


Use the navigation on the left to read about the available resources.

## Authentication

This provider requires a Dome9 API Key and Key secret  in order to manage the resources. This is obtained from the Dome9 [web application](https://secure.dome9.com/v2/settings/credentials). See [here](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk144514&partition=General&product=CloudGuard) for details how to obtain the Key and Secret.

To manage the full selection of resources, provide a
[Dome9 access id & secret key](https://secure.dome9.com/v2/settings/credentials) 
from an account with admin access permissions.


You can use the Key and Secret in the following ways:

- On the CLI, omit the `provider` block from your tf file, and the CLI will prompt for proper credentials.
  [CLI config file](/docs/commands/cli-config.html#credentials).
- Set the `DOME9_ACCESS_ID` and `DOME9_SECRET_KEY` environment variables.
- Fill the provider block with the appropriate arguments:    


```hcl
# Configure the Dome9 Provider
provider "dome9" {
  dome9_access_id     = "${var.access_id}"
  dome9_secret_key    = "${var.secret_key}"
}

# Create an organization
resource "dome9_cloudaccount_aws" "account" {
  # ...
}
```

### Argument Reference

* `dome9_access_id` - (Required) the Dome9 API Key
* `dome9_secret_key` - (Required) the Dome9  key secret