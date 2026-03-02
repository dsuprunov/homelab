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
  value = merge(
    {
      for name, record in var.dns_a_records :
        "${name}.${trimsuffix(record.zone, ".")}" => join(", ", record.addresses)
    }
  )
}

output "dns_cname_records" {
  value = merge(
    {
      for name, record in var.dns_cname_records :
        "${name}.${trimsuffix(record.zone, ".")}" => record.cname
    }
  )
}
