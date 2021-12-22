namespace "default" {
    policy = "read"
}

namespace "web-prod" {
    policy = "write"
    capabilities = ["sentinel-override"]
}

# agent policy rule covers utility operations in the Agent API
agent {
    policy = "read"
}

# node policy rule covers node-level catalog operations
node {
    policy = "write"
}

# quota policy rule covers quota specification related operations
quota {
    policy = "read"
}
