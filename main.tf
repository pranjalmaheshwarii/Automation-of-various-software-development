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
    startup-script = file("startup.sh")  # Reference to the startup script
  }

  tags = ["http-server"]

  service_account {
    scopes = ["cloud-platform"]
  }
}

output "instance_ip" {
  value = google_compute_instance.software_automation_vm.network_interface[0].access_config[0].nat_ip
}
