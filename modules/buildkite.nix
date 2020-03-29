{ config, pkgs, ... }:
{
  deployment.keys.buildkite-token = {
    text = builtins.getEnv "R13Y_BUILDKITE_TOKEN";
    user = config.users.extraUsers.buildkite-agent-r13y.name;
    group = "keys";
    permissions = "0600";
  };

  systemd.services.buildkite-agent-r13y = {
    after = [ "buildkite-token-key.service" ];
    wants = [ "buildkite-token-key.service" ];
    partOf = [ "buildkite-token-key.service" ];
  };

  services.buildkite-agents.r13y = {
    enable = true;
    tags = {
      r13y = "true";
      packet-spot = "true";
    };
    tokenPath = "/run/keys/buildkite-token";
    privateSshKeyPath = "/dev/null";
    runtimePackages = [ pkgs.xz pkgs.gzip pkgs.gnutar pkgs.gitAndTools.git-crypt pkgs.nix pkgs.bash ];
    hooks.environment = ''
      export PATH=$PATH:/run/wrappers/bin/
      export NIX_PATH=nixpkgs=${pkgs.path}
    '';
  };
}
