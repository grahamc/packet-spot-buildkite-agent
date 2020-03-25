let
  pkgs = import <nixpkgs> {};

  pins = {
    nixpkgs = {
      url = "https://github.com/nixos/nixpkgs-channels.git";
      branch = "nixos-unstable-small";
    };

    nixops = {
      url = "https://github.com/nixos/nixops.git";
      branch = "master";
    };

    nixops-packet = {
      url = "https://github.com/grahamc/nixops-packet.git";
      branch = "py3";
    };
  };

  pin_file = "${toString ./.}/pins.json";
in
rec {
  pinned = let
    sources = builtins.fromJSON (builtins.readFile ./pins.json);
  in
  builtins.mapAttrs (name: value:
    builtins.fetchGit {
      inherit (value) url rev;
      ref = pins."${name}".branch;
    }
  ) sources;

  update = pkgs.writeScript "update.sh" ''
    #!${pkgs.bash}/bin/bash

    set -euxo pipefail

    scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
    function finish {
      rm -rf "$scratch"
    }
    trap finish EXIT

    cd "$scratch"

    echo '{' > pins.json

    ${(pkgs.lib.concatStringsSep "\n")
    (pkgs.lib.mapAttrsToList
      (name: value: ''
        echo '"${name}": ' >> pins.json
        ${pkgs.nix-prefetch-git}/bin/nix-prefetch-git \
          ${value.url} \
          --rev "refs/heads/${value.branch}" >> pins.json
        echo , >> pins.json
      '')
      pins
    )}

    echo '"bogus": "bogus :)"}' >> pins.json
    ${pkgs.jq}/bin/jq 'del(.bogus)' pins.json > "${pin_file}"
  '';
}
