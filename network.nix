let
  secrets = import <secrets.nix>;
in {
  network.description = "buildkite-spot";

  defaults = {
    services.openssh.enable = true;

    # clean up time
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = let gbFree = 2000; in "--max-freed $((${toString gbFree} * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))";
    };
    systemd.tmpfiles.rules = [''
      e /tmp/nix-build-* - - - 1d -
    ''];
  };

  resources.packetKeyPairs.dummy = {
    inherit (secrets.deployment.packet) accessKeyId project;
  };

  buildkite-worker-kif = { resources, ... }: {
    deployment.targetEnv = "packet";
    deployment.packet = secrets.deployment.packet // {
      keyPair = resources.packetKeyPairs.dummy;
      facility = "ewr1";
      plan = "c2.medium.x86";
      spotInstance = true;
      spotPriceMax = "2.00";
      tags = {
        buildkite = "...yes...";
      };
    };

    nix.maxJobs = 12;
    nix.buildCores = 8;
    imports = [
      (import ./modules/buildkite.nix { inherit secrets; })
    ];
  };
}
