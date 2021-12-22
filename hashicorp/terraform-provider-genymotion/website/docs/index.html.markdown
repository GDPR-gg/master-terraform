---
layout: "genymotion"
page_title: "Provider: genymotion"
sidebar_current: "docs-genymotion-index"
description: |-
  Genymotion Cloud Provider is used to interact with many resources supported by Genymotion Cloud SaaS. The provider needs to be configured with the proper credentials before it can be used.
---

# Genymotion Cloud Provider

Genymotion Cloud provider is used to interact with the resource supported by [Genymotion Cloud SaaS](https://cloud.geny.io?&utm_source=web-referral&utm_medium=docs&utm_campaign=terraform&utm_content=signup). It will start Genymotion Cloud Android virtual devices that can directly be connected to adb to seamlessly run and scale your automated tests on them. The provider needs to be configured with the proper credentials before it can be used.

Genymotion Cloud provider needs gmsaas binary to be installed. You can easily install it with [Python3](https://www.python.org/downloads/)

```shell
# Install gmsaas binary
pip3 install gmsaas
````

You also must configure Android SDK path :

```shell
# Configure Android SDK path
gmsaas config set android-sdk-path <PATH_TO_ANDROID_SDK>
````

Use the navigation to the left to read about the available resource.

## Example Usage

```hcl
# Configure the Genymotion Provider
provider "genymotion" {
  email = "${var.email}"
  password = "${var.password}"
}

# Create an Genymotion Cloud SaaS Android instance
resource "genymotion_cloud" "Android90" {
  recipe_uuid = "143eb44a-1d3a-4f27-bcac-3c40124e2836"
  name     = "Android90"
}
```

## Authentication

Genymotion Cloud provider accepts several ways to enter credentials for authentication.
The following methods are supported, in this order, and explained below:

- Static credentials
- Environment variables

### Static credentials

Static credentials can be provided by adding an `email` and `password`  in-line in the
genymotion provider block:

Usage:

```hcl
provider "genymotion" {
  email = "${var.email}"
  password = "${var.password}"
}
```

### Environment variables

You can provide your credentials via `GENYMOTION_EMAIL` and `GENYMOTION_PASSWORD`,
environment variables, representing your Genymotion Cloud SaaS credentials.

```hcl
provider "genymotion" {}
```

Usage:

```shell
$ export GENYMOTION_EMAIL="your_genymotion_saas_email"
$ export GENYMOTION_PASSWORD="your_genymotion_saas_password"
$ terraform plan
```

## Argument Reference

The following arguments are supported:

- `email` - This is the Genymotion Cloud SaaS email account. It must be provided, but
  it can also be sourced from the `GENYMOTION_EMAIL` environment variable.

- `password` - This is the Genymotion Cloud SaaS password account. It must be provided, but
  it can also be sourced from the `GENYMOTION_PASSWORD` environment variable.

## Testing

Credentials must be provided via the `GENYMOTION_EMAIL`, and `GENYMOTION_PASSWORD` environment variables in order to run acceptance tests.