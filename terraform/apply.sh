#!/usr/bin/env nix-shell
#!nix-shell ../shell.nix -i bash
# shellcheck shell=bash

set -eux

scriptroot=$(dirname "$(realpath "$0")")

cd "$scriptroot/../terraform/"

terraform init
terraform apply -input=false -auto-approve

