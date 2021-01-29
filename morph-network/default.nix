{
  network = {
    pkgs =
      let
        sources = import ../nix/sources.nix;
      in
      import sources.nixpkgs {
        config = {
          allowUnfree = true;
        };
      };
    nixConfig = {
      builders = "";
      experimental-features = "nix-command";
    };
  };

  "buildkite-spot-0" = {
    deployment = {
      targetHost = "147.75.38.37";
      targetUser = "root";
      substituteOnDestination = true;
    };
    imports = [
      ../modules
      ./machines/buildkite-spot-0.expr.nix
      ./machines/buildkite-spot-0.system.nix
    ];
  };
}
