## 0.5.0 (Unreleased)
## 0.4.3 (July 27, 2020)

NOTES:

* add Terraform Plugin SDK dependencies

## 0.4.2 (July 27, 2020)

NOTES:

* add setting smtp_password support
* upgrade Mailgun client to newest version
* vendor update 

## 0.4.1 (October 22, 2019)

NOTES:

* adding hotfix for fallback to defalut region `us`

## 0.4.0 (October 22, 2019)

NOTES:

* adding support for Mailgun regions (`us` and `eu`) 

## 0.3.0 (October 16, 2019)

NOTES:

* adding support `terraform import` for Mailgun resources 

## 0.2.0 (October 07, 2019)

NOTES:

* adding support for Mailgunv3 API via official Go Mailgun client
* support for new resource type: `mailgun_route`
* small fixes and code cleanup
* refactoring: dependency management now is organized via go.mod (`go mod vendor`)

## 0.1.0 (June 21, 2017)

NOTES:

* Same functionality as that of Terraform 0.9.8. Repacked as part of [Provider Splitout](https://www.hashicorp.com/blog/upcoming-provider-changes-in-terraform-0-10/)
