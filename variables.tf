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

variable "ssh_user" {
  description = "The username for SSH access"
  type        = string
  default     = "maheshwaripreesha61"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "/home/maheshwaripreesha61/.ssh/id_rsa.pub"
}
