{ system ? builtins.currentSystem }:
let
  pins = (import ./config.nix).pinned;
  nixpkgs = let
    pkgs' = import pins.nixpkgs {};
  in
    pkgs'.stdenv.mkDerivation {
      name = "nixpkgs-${pins.nixpkgs.rev}";
      src = pins.nixpkgs;
      patches = [];
      phases = [ "unpackPhase" "patchPhase" "installPhase" ];
      installPhase = ''
        cd ..
        mv ./source $out
      '';
    };

in
import nixpkgs {
  config = {
    allowUnfree = true;
  };
  overlays = [
    (
      final: super: {}
    )
  ];
}
