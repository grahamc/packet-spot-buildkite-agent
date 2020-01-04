{ secrets }:
{ config, pkgs, ... }:
{
  deployment.keys.buildkite-token = {
    text = secrets.buildkite.token;
    user = config.users.extraUsers.buildkite-agent.name;
    group = "keys";
    permissions = "0600";
  };

  deployment.keys.buildkite-ssh-private = {
    text = builtins.readFile secrets.buildkite.ssh_key.private;
    user = config.users.extraUsers.buildkite-agent.name;
    group = "keys";
    permissions = "0600";
  };

  deployment.keys.buildkite-ssh-public = {
    text = builtins.readFile secrets.buildkite.ssh_key.public;
    user = config.users.extraUsers.buildkite-agent.name;
    group = "keys";
    permissions = "0600";
  };

  programs.ssh.knownHosts = [
    {
       hostNames = [ "flexo.gsc.io" "r13y.com" "147.75.105.137" ];
       publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZJC4F2C2DMZi1fonqMuWB1GdQR0bn3WRaEI3JYnE4d";
    }
  ];

  services.buildkite-agent = {
    enable = true;
    meta-data = "r13y=true,packet-spot=true";
    tokenPath = "/run/keys/buildkite-token";
    openssh.privateKeyPath = "/run/keys/buildkite-ssh-private";
    openssh.publicKeyPath = "/run/keys/buildkite-ssh-public";
    runtimePackages = [ pkgs.xz pkgs.gzip pkgs.gnutar pkgs.gitAndTools.git-crypt pkgs.nix pkgs.bash ];
    hooks.environment = ''
      export PATH=$PATH:/run/wrappers/bin/
      export NIX_PATH=nixpkgs=${pkgs.path}
    '';
  };
}
