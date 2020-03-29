{ system ? builtins.currentSystem }:
let
  pins = (import ./config.nix).pinned;
  nixpkgs = let pkgs' = import pins.nixpkgs {}; in
    pkgs'.stdenv.mkDerivation {
      name = "nixpkgs-${pins.nixpkgs.rev}";
      src = pins.nixpkgs;
      patches = [
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
      my-nixops = final.poetry2nix.mkPoetryEnv {
        projectDir = ./poetry;
        overrides = final.poetry2nix.overrides.withDefaults(
          self: super: {
            zipp = super.zipp.overridePythonAttrs(old: {
              propagatedBuildInputs = old.propagatedBuildInputs ++ [
                self.toml
              ];
            });

            nixops = super.nixops.overridePythonAttrs(old: {
              format = "pyproject";
              buildInputs = old.buildInputs ++ [ self.poetry ];
            });

            nixops-packet = super.nixops-packet.overridePythonAttrs(old: {
              format = "pyproject";
              buildInputs = old.buildInputs ++ [ self.poetry ];
            });

            packet-python = super.packet-python.overridePythonAttrs(old: {
              propagatedBuildInputs = old.propagatedBuildInputs ++ [
                self.pytest-runner
              ];
            });
          }
        );
      };
    })
  ];
}
