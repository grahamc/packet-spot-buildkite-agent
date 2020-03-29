let
  project = "86d5d066-b891-4608-af55-a481aa2c0094";
in {
  network = {
    description = "buildkite-spot";
    storage.s3 = {
      region = "us-east-1";
      bucket = "grahamc-nixops-state";
      key = "packet-spot-buildkite.nixops";
      kms_keyid = "166c5cbe-b827-4105-bdf4-a2db9b52efb4";
    };
  };

  defaults = {
    deployment.packet = {
      inherit project;
    };

    imports = [
      ./modules/default.nix
      ./modules/nix-collect-garbage.nix
    ];
  };

  resources.packetKeyPairs.dummy = {
    inherit project;
  };

  buildkite-worker = { resources, ... }: {
    deployment.targetEnv = "packet";
    deployment.packet = {
      inherit project;
      keyPair = resources.packetKeyPairs.dummy;
      facility = "ewr1";
      plan = "m1.xlarge.x86";
      ipxeScriptUrl = "http://139.178.89.161/current/907e8786.packethost.net/result/x86/netboot.ipxe";
      spotInstance = true;
      spotPriceMax = "2.00";
      tags = {
        buildkite = "...yes...";
      };
    };

    # nix.maxJobs = 12;
    nix.buildCores = 8;
    imports = [
      ./modules/buildkite.nix
    ];
  };
}
