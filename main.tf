variable "project_id" {
  type    = string
  default = "black-outlet-438804-p8"
}

variable "credentials_path" {
  type    = string
  default = "./black-outlet-438804-p8-7ce3a755dbe1.json"
}

variable "vm_name" {
  type    = string
  default = "software-automation-vm"
}

variable "vm_zone" {
  type    = string
  default = "us-central1-a"
}

variable "ssh_user" {
  type    = string
  default = "jenkins-user"
}

variable "ssh_public_key_path" {
  type    = string
  default = "/tmp/id_rsa.pub"
}

provider "google" {
  credentials = file(var.credentials_path)
  project     = var.project_id
  region      = "us-central1"
  zone        = var.vm_zone
}

resource "google_compute_instance" "software_automation_vm" {
  name         = var.vm_name
  machine_type = "e2-medium"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  tags = ["http-server"]

  service_account {
    scopes = ["cloud-platform"]
  }
}

output "instance_ip" {
  value = google_compute_instance.software_automation_vm.network_interface[0].access_config[0].nat_ip
}
