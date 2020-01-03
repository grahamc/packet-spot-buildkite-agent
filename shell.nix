let
  pkgs = import ./nix {};
in pkgs.mkShell {
  name = "packet-spot-buildkite";
  buildInputs = with pkgs; [
    nixops
  ];
}
