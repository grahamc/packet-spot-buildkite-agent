let
  pkgs = import ./nix {};
in pkgs.mkShell {
  name = "packet-spot-buildkite";
  buildInputs = with pkgs; [
    poetry
    my-nixops
    vault
  ];
  NIX_PATH = "nixpkgs=${pkgs.path}";
}
