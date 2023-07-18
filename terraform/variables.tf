variable "location" {
  type = string
  description = "Location of the resource"
}

variable "storage_account_name" {
  type = string
  description = "Name of Storage Account"
}

variable "resource_group_name" {
  type = string
  description = "Name of RG"
}

variable "user_assigned_identity"{
    type = list(string)
}