job "product-api" {
    region = "west"
    datacenters = ["cloud"]
    type = "service"
    constraint {
        attribute = "${attr.kernel.name}"
        value = "windows"
    }
    group "product-api" {
        count = 1
      	network {
      		port "http" {
              	static = 9090
            }
    	}
        task "product-api" {
            driver = "win_iis"

            artifact {
                source = "https://github.com/hashicorp/field-demos-nomad-land-team-footloose-wanderers-assets/raw/main/resources/product-api.zip"
                options {
                    checksum = "sha256:f94cf55361cfa8df6031c6a10cf733bae5289c23e99491a41b2b542509cf682c"
                }
            }

            config {
                path = "${NOMAD_TASK_DIR}"
                bindings {
                    type = "http"
                    port = "http"
                }
            }

            service {
                name = "product-api"
                tags = ["windows", "iis"]
                port = "http"
                check_restart {
                    grace = "60s"
                }
            }
        }
    }
}