let
  pkgs = import ./nix {};
  secrets = import <secrets.nix>;
in pkgs.mkShell {
  name = "packet-spot-buildkite";
  buildInputs = with pkgs; [
    poetry
    my-nixops
  ];
  NIX_PATH = "nixpkgs=${pkgs.path}";
}
