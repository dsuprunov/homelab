variable "dns_a_records" {
  type = map(object({
    zone      = optional(string, "home.arpa.")
    ttl       = optional(number, 300)
    addresses = list(string)
  }))
  default = {}
}

variable "dns_cname_records" {
  type = map(object({
    zone  = optional(string, "home.arpa.")
    ttl   = optional(number, 300)
    cname = string
  }))
  default = {}
}

resource "dns_a_record_set" "this" {
  for_each = var.dns_a_records

  zone      = each.value.zone
  name      = each.key
  ttl       = each.value.ttl
  addresses = each.value.addresses
}

resource "dns_cname_record" "this" {
  for_each = var.dns_cname_records

  zone  = each.value.zone
  name  = each.key
  ttl   = each.value.ttl
  cname = each.value.cname
}

output "dns_a_records" {
  description = "Managed A records."
  value = {
    for name, r in dns_a_record_set.this :
    name => {
      zone      = r.zone
      name      = r.name
      ttl       = r.ttl
      addresses = r.addresses
    }
  }
}

output "dns_cname_records" {
  description = "Managed CNAME records."
  value = {
    for name, r in dns_cname_record.this :
    name => {
      zone  = r.zone
      name  = r.name
      ttl   = r.ttl
      cname = r.cname
    }
  }
}
