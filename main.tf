provider "google" {
  credentials = file("${path.module}/black-outlet-438804-p8.json")
  project     = "black-outlet-438804-p8"
  region      = "us-central1"
  zone        = "us-central1-a"
}

resource "google_compute_instance" "software_automation_vm" {
  name         = "software-automation-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

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
    ssh-keys = "maheshwaripreesha61:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["jenkins", "cicd"]
}
