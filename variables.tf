variable "health_check_interval" {
  default = "30"
}

# The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused
variable "deregistration_delay" {
  default = "30"
}

variable "region" {
  default = "us-east-1"
}

# Tags for the infrastructure
variable "tags" {
  type = map(string)
  default = {
    test = "testing"
  }
}

# The application's name
variable "app" {
    default = "test"
}

# The environment that is being built
variable "environment" {
    default = "dev"
}

# # The port the container will listen on, used for load balancer health check
# # Best practice is that this value is higher than 1024 so the container processes
# # isn't running at root.
# variable "container_port" {
# }

# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "TCP"
}

# Network configuration

#The VPC to use for the Fargate cluster
variable "vpc" {
    default = "vpc-f176f28c"
}

# # The private subnets, minimum of 2, that are a part of the VPC(s)
variable "private_subnets" {
    default = "subnet-9e394dc1,subnet-7a0a611c,subnet-4dc9f100"
}


variable "replicas" {
  default = "1"
}

# The name of the container to run
variable "container_name" {
  default = "app"
}

# The minimum number of containers that should be running.
# Must be at least 1.
# used by both autoscale-perf.tf and autoscale.time.tf
# For production, consider using at least "2".
# variable "ecs_autoscale_min_instances" {
#   default = "1"
# }

# The maximum number of containers that should be running.
# used by both autoscale-perf.tf and autoscale.time.tf
# variable "ecs_autoscale_max_instances" {
#   default = "8"
# }

# variable "default_backend_image" {
#   default = "quay.io/turner/turner-defaultbackend:0.2.0"
# }

  
variable "api_usage_quota_limit" {
  type        = number
  default     = 1000
  description = "The maximum number of requests that can be made in a given time period"
}

variable "api_usage_quota_offset" {
  type        = number
  default     = 5
  description = "The number of requests subtracted from the given limit in the initial time period"
}

variable "api_usage_quota_period" {
  type        = string
  default     = "DAY"
  description = "The time period in which the limit applies. Valid values are 'DAY, 'WEEK' or 'MONTH'"
}

variable "api_usage_burst_limit" {
  type        = number
  default     = 10
  description = "The API request burst limit, the maximum rate limit over a time ranging from one to a few seconds, depending upon whether the underlying token bucket is at its full capacity"
}

variable "api_usage_rate_limit" {
  type        = number
  default     = 20
  description = "The API request steady-state rate limit"
}

variable "instance_ip_address"
{
    default = "10.1.1.1"
}