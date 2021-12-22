job "legacy-app" {
    region = "east"
    datacenters = ["on-prem"]
    type = "service"
    constraint {
        attribute = "${attr.kernel.name}"
        value = "windows"
    }
    group "legacy-app" {
        count = 1
      	network {
      		port "http" {
              	static = 8080
            }
    	}
        task "legacy-app" {
            driver = "win_iis"

            artifact {
                source = "https://github.com/hashicorp/field-demos-nomad-land-team-footloose-wanderers-assets/raw/main/resources/legacy-app.zip"
                options {
                    checksum = "sha256:8b3cb05f8074c02e12d00e8cb4f7327288d14a0b97b9b724f42d292dc1f1affe"
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
                name = "legacy-app"
                tags = ["windows", "iis"]
                port = "http"
                check_restart {
                    grace = "60s"
                }
            }
        }
    }
}