job "payment-api" {
    type        = "service"
    
    multiregion {
        strategy {
            max_parallel = 1
            on_failure   = "fail_all"
        }
        region "west" {
            count       = 1
            datacenters = ["cloud"]
        }
        region "east" {
            count       = 1
            datacenters = ["on-prem"]
        }
    }

    update {
        max_parallel      = 1
        min_healthy_time  = "10s"
        healthy_deadline  = "2m"
        progress_deadline = "3m"
        auto_revert       = true
        auto_promote      = true
        canary            = 1
    }

    constraint {
        attribute = "${attr.driver.podman.rootless}"
        value = "false"
    }

    group "payment-api" {
        count = 1
      	network {
      		port "api" {
              	static = 8080
            }
    	}
        task "payment-api" {
            driver = "java"

            artifact {
                source = "https://github.com/hashicorp-demoapp/payments/releases/download/v0.0.11/spring-boot-payments-0.0.11.jar"
            }

            config {
                jar_path    = "${NOMAD_TASK_DIR}/spring-boot-payments-0.0.11.jar"
                jvm_options = ["-Xmx512m", "-Xms256m"]
            }

            resources {
                cpu    = 256
                memory = 512
            }

            service {
                name = "payment-api"
                tags = ["podman","java"]
                port = "api"
                check_restart {
                    grace = "600s"
                }
            }
        }
    }
}