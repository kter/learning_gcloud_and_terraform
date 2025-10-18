variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
}

variable "cloudrun_service_name" {
  type        = string
  description = "Name of the Cloud Run service"
}

variable "neg_name" {
  type        = string
  description = "Name of the Network Endpoint Group"
  default     = "neg"
}

variable "backend_service_name" {
  type        = string
  description = "Name of the backend service"
  default     = "backend-service"
}

variable "https_url_map_name" {
  type        = string
  description = "Name of the HTTPS URL map"
  default     = "https-url-map"
}

variable "http_url_map_name" {
  type        = string
  description = "Name of the HTTP URL map"
  default     = "http-url-map"
}

variable "certificate_name" {
  type        = string
  description = "Name of the SSL certificate"
  default     = "certificate"
}

variable "domains" {
  type        = list(string)
  description = "List of domains for the SSL certificate"
}

variable "target_https_proxy_name" {
  type        = string
  description = "Name of the HTTPS target proxy"
  default     = "target-https-proxy"
}

variable "target_http_proxy_name" {
  type        = string
  description = "Name of the HTTP target proxy"
  default     = "target-http-proxy"
}

variable "global_address_name" {
  type        = string
  description = "Name of the global address"
  default     = "address"
}

variable "https_forwarding_rule_name" {
  type        = string
  description = "Name of the HTTPS forwarding rule"
  default     = "https-rule"
}

variable "http_forwarding_rule_name" {
  type        = string
  description = "Name of the HTTP forwarding rule"
  default     = "http-rule"
}

variable "dns_zone_name" {
  type        = string
  description = "Name of the DNS managed zone (optional)"
  default     = ""
}

variable "dns_record_name" {
  type        = string
  description = "DNS record name (optional)"
  default     = ""
}

variable "dns_ttl" {
  type        = number
  description = "TTL for DNS records"
  default     = 300
}
