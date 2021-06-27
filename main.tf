terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "=1.19.0"
    }
  }
  backend "s3" {
  }
}

provider "linode" {
}

resource "linode_lke_cluster" "portfolio_cluster" {
  label       = "portfolio"
  k8s_version = "1.21"
  region      = "ap-south"

  pool {
    type  = "g6-standard-1"
    count = 3
  }
}
