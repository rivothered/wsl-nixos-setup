{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # Golang
    go

    # Java
    temurin-bin
    maven
    gradle

    # Python
    python3Full

    # NodeJS
    nodejs

    # Other tools
    wget
    curl
    git
    pre-commit
  ];

  # VSCode Remote
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };
}
