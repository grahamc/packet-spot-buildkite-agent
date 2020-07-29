#!/usr/bin/env nix-shell
#!nix-shell -i bash

set -eux

export R13Y_BUILDKITE_TOKEN=$(vault kv get -field=token secret/buildkite/grahamc/token)
# nixops packet update-provision buildkite-worker || true # busted on this version of nixops-packet
nixops deploy --check --allow-recreate --kill-obsolete --confirm
