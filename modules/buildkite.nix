{ secrets }:
{ config, pkgs, ... }:
{
  deployment.keys.buildkite-token = {
    text = secrets.buildkite.token;
    user = config.users.extraUsers.buildkite-agent-r13y.name;
    group = "keys";
    permissions = "0600";
  };

  deployment.keys.buildkite-ssh-private = {
    text = builtins.readFile secrets.buildkite.ssh_key.private;
    user = config.users.extraUsers.buildkite-agent-r13y.name;
    group = "keys";
    permissions = "0600";
  };

  programs.ssh.knownHosts = {
    "flexo.gsc.io" = {
       hostNames = [ "flexo.gsc.io" "r13y.com" "147.75.105.137" ];
       publicKey ="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZJC4F2C2DMZi1fonqMuWB1GdQR0bn3WRaEI3JYnE4d";
    };
  };

  systemd.services.buildkite-agent-r13y = {
    after = [ "buildkite-ssh-private-key.service" "buildkite-token-key.service" ];
    wants = [ "buildkite-ssh-private-key.service" "buildkite-token-key.service" ];
    partOf = [ "buildkite-ssh-private-key.service" "buildkite-token-key.service" ];
  };

  services.buildkite-agents.r13y = {
    enable = true;
    tags = {
      r13y = true;
      packet-spot = true;
    };
    tokenPath = "/run/keys/buildkite-token";
    privateSshKeyPath = "/run/keys/buildkite-ssh-private";
    runtimePackages = [ pkgs.xz pkgs.gzip pkgs.gnutar pkgs.gitAndTools.git-crypt pkgs.nix pkgs.bash ];
    hooks.environment = ''
      export PATH=$PATH:/run/wrappers/bin/
      export NIX_PATH=nixpkgs=${pkgs.path}
    '';
  };
}
