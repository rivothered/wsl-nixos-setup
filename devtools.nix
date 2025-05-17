{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # Rust
    rustup    
    gdb
    gcc
    gnumake
    cmake
    glibc
    glib
    libllvm

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

    # Microbit (Rust)
    minicom
    libunwind
    probe-rs-tools
    cargo-binutils

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
