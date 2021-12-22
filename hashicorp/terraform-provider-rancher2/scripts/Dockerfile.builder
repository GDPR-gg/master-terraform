FROM golang:1.13.11-alpine3.11
RUN apk -U add bash git gcc musl-dev make docker-cli curl ca-certificates
WORKDIR /go/src/github.com/terraform-providers/terraform-provider-rancher2