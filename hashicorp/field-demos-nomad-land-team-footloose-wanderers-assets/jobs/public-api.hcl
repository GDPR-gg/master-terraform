job "public-api" {
    region = "west"
    datacenters = ["cloud"]
    type = "service"
    constraint {
        attribute = "${attr.kernel.name}"
        value = "linux"
    }
    group "hashicups" {
        count = 1
        network {
      		port "api" {
              	static = 9080
            }
    	}
        task "public-api" {
            driver = "docker"

            env {
                BIND_ADDRESS = ":9080"
                PRODUCT_API_URI = "http://product-api.service.consul:9090"
                PAYMENT_API_URI = "http://payment-api.service.consul:8080"
            }

            config {
                image = "hashicorpdemoapp/public-api:v0.0.4"
                dns_servers = ["172.17.0.1"]
                ports = ["api"]
            }

            resources {
                cpu    = 256
                memory = 512
            }

            service {
                name = "public-api"
                tags = ["docker", "linux"]
                port = "api"
                check_restart {
                    grace = "600s"
                }
            }
        }
    }
}