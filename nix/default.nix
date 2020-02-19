{ system ? builtins.currentSystem }:
let
  pins = (import ./config.nix).pinned;
  nixpkgs = let pkgs' = import pins.nixpkgs {}; in
    pkgs'.stdenv.mkDerivation {
      name = "nixpkgs-${pins.nixpkgs.rev}";
      src = pins.nixpkgs;
      patches = [
        ./0001-buildkite-fixup-https-github.com-NixOS-nixpkgs-pull-.patch
      ];
      phases = [ "unpackPhase" "patchPhase" "installPhase" ];
      installPhase = ''
        cd ..
        mv ./source $out
      '';
    };

in import nixpkgs {
  overlays = [
    (final: super: {
      nixops-packet = (import "${pins.nixops-packet}/release.nix" {
        nixopsSrc = pins.nixops;
        nixpkgs = final.path;
      }); # Note: has structure like:
      # nixops-packet.build.x86_64-linux = ....
      # and nixops' plugin support handles this automatically.

      nixops = (import "${pins.nixops}/release.nix" {
        nixopsSrc = pins.nixops;
        nixpkgs = final.path;
        p = (nixopsPlugins: [
          final.nixops-packet
        ]);
     }).build."${system}";
    })
  ];
}
