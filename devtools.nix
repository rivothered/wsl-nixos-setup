{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # Golang
    go

    # Terraform
    terraform

    # Python
    python3Full

    # NodeJS
    nodejs

    # Other tools
    wget
    curl
    git
    gnupg
    pinentry-curses
    pre-commit
  ];

  # VSCode Remote
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };
}
