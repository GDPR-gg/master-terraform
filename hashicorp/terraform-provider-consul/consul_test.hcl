ui = true
primary_datacenter = "dc1"

limits = {
    http_max_conns_per_client = -1
}

acl = {
    enabled = true
    default_policy = "allow"
    down_policy = "extend-cache"

    tokens = {
        master = "master-token"
    }
}

retry_join_wan = ["127.0.0.1:8307"]
