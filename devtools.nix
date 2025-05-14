{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # GNU build toolchain extras
    bison
    pkg-config
    gnumake
    gcc
    autoconf
    automake
    libtool

    # Golang
    go

    # Rust
    rustup

    # Python
    pyenv

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
