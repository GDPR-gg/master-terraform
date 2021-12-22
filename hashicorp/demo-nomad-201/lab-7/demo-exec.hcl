job "demo-exec" {
  datacenters = ["dc1"]
  namespace   = "web-prod"

  group "demo-exec" {
    count = 1
    task "server" {
      driver = "exec"

      config {
        command = "local/project"
      }

      artifact {
        source      = "https://s3-us-west-2.amazonaws.com/hashicorp-education/demo-binaries/project"
        destination = "local/project"
        mode        = "file"
      }

      resources {
        cpu    = 200
        memory = 256
        network {
          port "web" {}
        }
      }

      service {
        name = "demo-exec"
        port = "web"

        check {
          type     = "tcp"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
