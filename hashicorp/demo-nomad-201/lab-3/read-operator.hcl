# namespace policy rule covers job-related operations by namespace
namespace "default" {
    policy = "read"
}

namespace "web-prod" {
    policy = "read"
}

# agent policy rule covers utility operations in the Agent API
agent {
    policy = "read"
}

# node policy rule covers node-level catalog operations
node {
    policy = "read"
}

# quota policy rule covers quota specification related operations
quota {
    policy = "read"
}
