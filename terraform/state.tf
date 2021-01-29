terraform {
  backend "s3" {
    bucket = "grahamc-nixops-state"
    key = "grahamc-packet-spot-buildkite-agent/terraform.tfstate"
    region = "us-east-1"
    kms_key_id = "166c5cbe-b827-4105-bdf4-a2db9b52efb4"
  }

  required_providers {
    metal = {
      source = "nixpkgs/metal"
    }
  }
}

variable "tags" {
  type    = list(string)
  default = ["terraform-buildkite-spot"]
}

