{
  network = {
    pkgs = import ../nix {};
    nixConfig = {
      builders = "";
      experimental-features = "nix-command";
    };
  };

}
