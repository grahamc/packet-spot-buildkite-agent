{ pkgs, ... }: {
  # clean up time
  nix.gc = {
    automatic = true;
    dates = "hourly";
    options = let gbFree = 2000; in "--max-freed $((${toString gbFree} * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))";
  };
  systemd.tmpfiles.rules = [''
    e /tmp/nix-build-* - - - 1d -
  ''];
}
