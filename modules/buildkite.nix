{ config, pkgs, ... }:
{
  deployment = {
    secrets = {
      buildkite-token = {
        source = "../buildkite.token";
        destination = "/run/keys/buildkite-token";
        owner.user = config.users.extraUsers.buildkite-agent-r13y.name;
        owner.group = "keys";
        permissions = "0600"; # this is the default
        action = [ "sudo" "systemctl" "restart" "buildkite-agent-r13y.service" ];
      };
    };
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
