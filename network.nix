let
  secrets = import <secrets.nix>;
in {
  network.description = "buildkite-spot";

  defaults = {
    imports = [
      ./modules/default.nix
      ./modules/nix-collect-garbage.nix
    ];
  };

  resources.packetKeyPairs.dummy = {
    inherit (secrets.deployment.packet) accessKeyId project;
  };

  buildkite-worker = { resources, ... }: {
    deployment.targetEnv = "packet";
    deployment.packet = secrets.deployment.packet // {
      keyPair = resources.packetKeyPairs.dummy;
      facility = "ewr1";
      plan = "m1.xlarge.x86";
      ipxeScriptUrl = "http://907e8786.packethost.net/result/x86/netboot.ipxe";
      spotInstance = true;
      spotPriceMax = "2.00";
      tags = {
        buildkite = "...yes...";
      };
    };

    # nix.maxJobs = 12;
    nix.buildCores = 8;
    imports = [
      (import ./modules/buildkite.nix { inherit secrets; })
    ];
  };
}
