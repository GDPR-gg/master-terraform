job "product-db" {
    region = "east"
    datacenters = ["on-prem"]
    type        = "service"
    constraint {
        attribute = "${attr.kernel.name}"
        value = "windows"
    }
    group "product-db" {
        count = 1
        network {
            port "db" {
                static = 1433
                to = 1433
            }
        }
        service {
            name = "product-db"
            tags = ["windows", "sqlserver"]
            port = "db"
            check_restart {
                grace = "600s"
            }
        }
        task "product-db" {
            driver = "docker"
            config {
                image = "pgryzan/product-db:20210506"
                image_pull_timeout = "15m"
                ports = ["db"]
                force_pull = false
            }
            resources {
                cpu = 2000 # Mhz
                memory = 2048 # MB
            }
        }
    }
}