terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "=1.28.0"
    }
  }
  # # Uncomment this to use Linode Object Storage backend.
  # backend "s3" {
  # }
}

provider "linode" {
}

resource "linode_lke_cluster" "default_cluster" {
  label       = "default"
  k8s_version = "1.23"
  region      = "ap-south"

  pool {
    type  = "g6-standard-1"
    count = 1
  }
}
