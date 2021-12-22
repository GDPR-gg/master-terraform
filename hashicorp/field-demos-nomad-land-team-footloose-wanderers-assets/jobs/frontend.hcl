job "frontend" {
    region      = "west"
    datacenters = ["cloud"]
    type        = "service"

    constraint {
        attribute = "${attr.kernel.name}"
        value = "linux"
    }

    group "frontend" {
        count = 1

        network {
            port "http" {
                static = 80
            }
        }

        restart {
            attempts = 10
            interval = "5m"
            delay    = "15s"
            mode     = "delay"
        }

        task "server" {
            driver = "docker"

            # Task relevant environment variables necessary
            env {
                PORT    = "${NOMAD_PORT_http}"
                NODE_IP = "${NOMAD_IP_http}"
            }

            # Frontend Docker image location and configuration
            config {
                image = "hashicorpdemoapp/frontend:v0.0.4"
                dns_servers = ["172.17.0.1"]
                volumes = [
                    "local:/etc/nginx/conf.d"
                ]
                ports = ["http"]
            }

            # Creation of the NGINX configuration file
            template {
                data = <<EOF
resolver 172.17.0.1 valid=1s;
server {
    listen       80;
    server_name  localhost;
    set $upstream_endpoint public-api.service.consul;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
    # Proxy pass the api location to save CORS
    # Use location exposed by Consul connect
    location /api {
        proxy_pass http://$upstream_endpoint:9080;
        # Need the next 4 lines. Else browser might think X-site.
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
                destination   = "local/default.conf"
                change_mode   = "signal"
                change_signal = "SIGHUP"
            }

            # Host machine resources required
            resources {
                cpu = 100
                memory = 256
            }

            # Service definition to be sent to Consul with corresponding health check
            service {
                name = "frontend"
                port = "http"

                tags = ["docker", "ubuntu"]

                check {
                    type     = "http"
                    path     = "/"
                    interval = "2s"
                    timeout  = "2s"
                }
            }
        }
    }
}