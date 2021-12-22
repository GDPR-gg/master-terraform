network "dc1" {
  subnet = "10.5.0.0/16"
}

//
// Create a single node Kubernetes cluster.
//
k8s_cluster "dc1" {
  driver  = "k3s"
  version = "v1.18.15"

  nodes = 1

  network {
    name = "network.dc1"
  }
}

//
// Install Consul using the helm chart.
//
helm "consul" {
  cluster = "k8s_cluster.dc1"

  // chart = "github.com/hashicorp/consul-helm?ref=crd-controller-base"
  chart = "github.com/hashicorp/consul-helm?ref=v0.30.0"
  values = "./config/consul-helm-values.yaml"

  health_check {
    timeout = "60s"
    pods = ["app=consul"]
  }
}

ingress "consul-http" {

  destination {
    driver = "k8s"

    config { 
      cluster = "k8s_cluster.dc1"
      address = "consul-server.default.svc"
      port = 8500
    }
  }
  
  source {
    driver = "local"

    config {
      port = 8500
   }

  }
}

ingress "consul-lan-rpc" {

  destination {
    driver = "k8s"

    config { 
      cluster = "k8s_cluster.dc1"
      address = "consul-server.default.svc"
      port = 8300
    }
  }
  
  source {
    driver = "local"

    config {
      port = 8300
   }

  }
}

ingress "consul-lan-serf" {

  destination {
    driver = "k8s"

    config { 
      cluster = "k8s_cluster.dc1"
      address = "consul-server.default.svc"
      port = 8301
    }
  }
  
  source {
    driver = "local"

    config {
      port = 8301
   }

  }
}