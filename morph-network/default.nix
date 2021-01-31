{
  network = {
    pkgs = import ../nix {};
    nixConfig = {
      builders = "";
      experimental-features = "nix-command";
    };
  };

  "buildkite-spot-0" = {
    deployment = {
      targetHost = "147.75.199.51";
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
