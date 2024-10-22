variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "credentials_path" {
  description = "The path to the service account credentials JSON file"
  type        = string
}

variable "vm_name" {
  description = "The name of the VM instance"
  type        = string
}

variable "vm_zone" {
  description = "The zone where the VM will be created"
  type        = string
}
