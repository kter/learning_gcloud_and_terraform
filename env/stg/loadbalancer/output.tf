output "global_address" {
  value       = module.loadbalancer.global_address
  description = "The global IP address of the load balancer"
}
