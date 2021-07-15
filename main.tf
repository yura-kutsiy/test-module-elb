/*
In this module you can configure
application load balancerbetween two instances.
Enter your key_pair for instance, choose instance type,
opne ports,
*/

module "instance" {
  source = "./modules/elb"

  region = "eu-central-1"

  key_pair        = "aws-key"
  instance_type   = "t2.micro"
  user_data       = file("server.sh")
  allow_tcp_ports = ["80", "443", "22"]

  server_name       = "module-named-instance"
  server_desription = "server-from-module"

  load_balancer_name = "app-load-balancer-php"
}

output "dns_name" {
  value = module.instance.lb_url
}
