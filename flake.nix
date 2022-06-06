{
  description = "equinix-metal-buildkite-agent";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nix-netboot-serve.url = "github:DeterminateSystems/nix-netboot-serve/standard-modules";
  };

  outputs =
    { self
    , nixpkgs
    , nix-netboot-serve
    , ...
    } @ inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      allSystems = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" ];

      forAllSystems = f: genAttrs allSystems (system: f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShell = forAllSystems
        ({ system, pkgs, ... }: pkgs.mkShell {
          nativeBuildInputs = (with pkgs; [
            vault
            awscli
            jq
            (
              pkgs.terraform_0_14.withPlugins (
                p: [
                  p.metal
                ]
              )
            )

          ]);
        });

      hydraJobs.builder = self.nixosConfigurations.builder.config.system.build.toplevel;

      nixosConfigurations.builder = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./modules
          nix-netboot-serve.nixosModules.no-filesystem
          nix-netboot-serve.nixosModules.register-nix-store
          nix-netboot-serve.nixosModules.swap-to-disk
          nix-netboot-serve.nixosModules.tmpfs-root
        ];
      };
    };
}
