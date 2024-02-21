variable "zone" {
  description = "Hosted DNS zone."
  type = object({
    id   = string
    name = string
  })
}

variable "name" {
  description = "Name of the KSK."
  type        = string
}
