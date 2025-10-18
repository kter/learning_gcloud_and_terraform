output "vpc_network" {
  value = module.vpc.vpc_network_self_link
}

output "vpc_network_name" {
  value = module.vpc.vpc_network_name
}

output "subnetwork" {
  value = module.vpc.subnetwork_self_link
}

output "subnetwork_name" {
  value = module.vpc.subnetwork_name
}