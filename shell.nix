let
  pkgs = import ./nix {};
in pkgs.mkShell {
  name = "packet-spot-buildkite";
  buildInputs = with pkgs; [
    nixops
  ];

  NIXOPS_STATE = "${toString ./.}/private/nixops-state/deployments.nixops";
  NIXOPS_DEPLOYMENT = "packet-spot-buildkite";
  NIX_PATH = "nixpkgs=${pkgs.path}";
}
