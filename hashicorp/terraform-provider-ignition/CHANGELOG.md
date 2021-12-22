## 1.2.2 (Unreleased)
## 1.2.1 (December 12, 2019)
## 1.2.0 (December 04, 2019)

IMPROVEMENTS:

* Bump Terraform SDK to 1.4.0
* Wrap the errors with an extra message
* Remove unused functions
* Update documentation

BUG FIXES:

* Remove in-memory cache (#57)

## 1.1.0 (May 28, 2019)

IMPROVEMENTS:

* Updated directory mode to take both octal and decimal.
* Adapt to Go 1.11+ and enable modules
* Bump Terraform SDK to v0.12.0 and tidy up modules

BUG FIXES:

* Typo on ignition_systemd_unit docs
* Fix typos in README.md
* Rename resourceX to dataSourceX to reflect reality (only datasources present).

## 1.0.1 (May 29, 2018)
NOTES:

- [[#13](https://github.com/terraform-providers/terraform-provider-ignition/issues/13)] introduced a regression with rendered configuration for the
  `ignition_config` resource, and was released in version 1.0.0. ([#23](https://github.com/terraform-providers/terraform-provider-ignition/issues/23))
  restores the correct behavior. As a result, the rendered output of
  `ignition_config` may change when upgrading to this version

## 1.0.0 (September 13, 2017)

IMPROVEMENTS: 

- Implementation of Ignition 2.1 [\#13](https://github.com/terraform-providers/terraform-provider-ignition/pull/13)
- \*: validation of the values using the `types.\*.Validate\*` functions [\#14](https://github.com/terraform-providers/terraform-provider-ignition/pull/14)
- \*: remove deprecate resources in favor of data resources [\#15](https://github.com/terraform-providers/terraform-provider-ignition/pull/15)

## 0.2.0 (September 5, 2017)

IMPROVEMENTS: 
  
- Ignition config should be marshaled as compact JSON [\#2](https://github.com/terraform-providers/terraform-provider-ignition/issues/2)
- Allow users to omit the optional verification hashes [\#9](https://github.com/terraform-providers/terraform-provider-ignition/pull/9)
- vendor: github.com/hashicorp/terraform/...@v0.10.0 [\#11](https://github.com/terraform-providers/terraform-provider-ignition/pull/11)

BUG FIXES:

- Added nil check for empty lists in Ignition Config builders [\#7](https://github.com/terraform-providers/terraform-provider-ignition/pull/7)
- Fixed issue with ignition\_filesystem when empty options passed in [\#5](https://github.com/terraform-providers/terraform-provider-ignition/pull/5)
- ignition\_config: render to non-indented json [\#3](https://github.com/terraform-providers/terraform-provider-ignition/pull/3)


## 0.1.0 (June 20, 2017)

NOTES:

* Same functionality as that of Terraform 0.9.8. Repacked as part of [Provider Splitout](https://www.hashicorp.com/blog/upcoming-provider-changes-in-terraform-0-10/)
