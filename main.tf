provider "google" {
  credentials = file(var.credentials_path)
  project     = var.project_id
  region      = "us-central1"
  zone        = var.vm_zone
}

resource "google_compute_instance" "software_automation_vm" {
  name         = var.vm_name
  machine_type = "e2-medium"
  zone         = var.vm_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP for external access
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  tags = ["jenkins", "cicd"]
}
