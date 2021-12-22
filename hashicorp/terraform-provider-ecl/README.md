<!-- archived-provider -->
Please note: This Terraform provider is archived, per our [provider archiving process](https://terraform.io/docs/internals/archiving.html). What does this mean?
1. The code repository and all commit history will still be available.
1. Existing released binaries will remain available on the releases site.
1. Issues and pull requests are not being monitored.
1. New releases will not be published.

If anyone from the community or an interested third party is willing to maintain it, they can fork the repository and [publish it](https://www.terraform.io/docs/registry/providers/publishing.html) to the Terraform Registry. If you are interested in maintaining this provider, please reach out to the [Terraform Provider Development Program](https://www.terraform.io/guides/terraform-provider-development-program.html) at *terraform-provider-dev@hashicorp.com*.

Terraform Enterprise Cloud Provider
===================================

Maintainers
-----------

This provider plugin is maintained by:

* Keiichi Hikita ([@keiichi-hikita](https://github.com/keiichi-hikita))
* Takuma Watanabe ([@t-wata](https://github.com/t-wata))
* Kazunori Yoshihara ([@kazyshr](https://github.com/kazyshr))
* Hitoyoshi Ohta ([@htysh](https://github.com/htysh))

Requirements
------------

- [Terraform](https://www.terraform.io/downloads.html) 0.12.x
- [Go](https://golang.org/doc/install) 1.13 (to build the provider plugin)

Building The Provider
---------------------

Clone repository to anywhere you want: 

```sh
$ git clone https://github.com/nttcom/terraform-provider-ecl 
```

Enter the provider directory and build the provider

```sh
$ cd terraform-provider-ecl
$ make build
```

Using the provider
----------------------
You can browse the documentation within this repo [here](https://github.com/nttcom/terraform-provider-ecl/tree/master/website/docs).

Developing the Provider
---------------------------

If you wish to work on the provider, you'll first need [Go](http://www.golang.org) installed on your machine (version 1.8+ is *required*). You'll also need to correctly setup a [GOPATH](http://golang.org/doc/code.html#GOPATH), as well as adding `$GOPATH/bin` to your `$PATH`.

To compile the provider, run `make build`. This will build the provider and put the provider binary in the `$GOPATH/bin` directory.

```sh
$ make build
...
$ cp terraform-provider-ecl $GOPATH/bin/terraform-provider-ecl
...
```
