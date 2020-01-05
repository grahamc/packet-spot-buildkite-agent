let
  pkgs = import ./nix {};
  secrets = import <secrets.nix>;
in pkgs.mkShell {
  name = "packet-spot-buildkite";
  buildInputs = with pkgs; [
    nixops
  ];

  NIXOPS_STATE = secrets.nixops-state-file;
  NIXOPS_DEPLOYMENT = "packet-spot-buildkite";
  NIX_PATH = "nixpkgs=${pkgs.path}:secrets=${<secrets.nix>}";
}
