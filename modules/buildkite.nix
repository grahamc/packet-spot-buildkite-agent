{ config, pkgs, ... }:
{
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
