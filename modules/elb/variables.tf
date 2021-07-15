variable "region" {
  default = ""
}

# variable "instance_count" {
#   default = ""
# }

variable "instance_type" {
  default = ""
}

variable "user_data" {
  default = ""
}

# variable "subnet_id" {
#   default = ""
# }

# variable "security_groups" {
#   default = ""
# }

variable "key_pair" {
  default = ""
}

variable "server_name" {
  default = ""
}

variable "server_desription" {
  default = ""
}

variable "allow_tcp_ports" {
  description = "List of open ports"
  default     = [] #["80", "443", "22"]
  type        = list(any)
}

variable "load_balancer_name" {
  default = ""
}
