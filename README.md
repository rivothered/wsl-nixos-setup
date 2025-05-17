# Rivo WSL Setup

![NixOS Rivo Setup Logo](https://github.com/rivothered/wsl-nixos-setup/blob/main/assets/logo.png "NixOS Rivo Setup Logo")

This PowerShell script automates the process of installing and configuring [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) with a custom user setup.

## Features

* Downloads the latest `nixos.wsl` release from GitHub
* Imports the distribution into WSL with a custom name
* Creates a new user and sets it as the default for WSL
* Updates configuration.nix with custom modules
* Automatically includes devtools.nix module
* Applies system rebuild with nixos-rebuild switch
* Removes the default `nixos` user
* Removes icon from Windows Terminal profile to avoid rendering warnings
* Fully reloads WSL with the new configuration
* Cleans up temporary files

## Usage

1. Open PowerShell as Administrator.
2. Run the script.
3. Enter the desired new username and password when prompted.

## Quick Setup

To run the script directly from PowerShell:
```powershell
irm -useb https://raw.githubusercontent.com/rivothered/wsl-nixos-setup/refs/heads/main/nixos-wsl-install.ps1 | iex
```

## Prerequisites

* Windows 10/11 with WSL2 enabled
* PowerShell 5.1 or newer
* Internet connection to download the release

## Steps Performed by the Script

1. **Download and register the NixOS distribution**

   * Downloads the latest `nixos.wsl` from the GitHub release.
   * Registers the distro with WSL using the name `NixOS` (modifiable in the script).

2. **Create a new user**

   * Prompts for username and password.
   * Creates the user with `useradd` and adds to `wheel` group.

3. **Set the new user as default in `configuration.nix`**

   * Replaces the line `wsl.defaultUser = "nixos"` with the new username.

4. **Get development tools file `devtools.nix`**

   * Download `devtoolx.nix` from main branch of this repo.

5. **Rebuild system configuration**

   * Updates NixOS channels and runs `nixos-rebuild switch`.

6. **Remove icon from Windows Terminal profile**

   * Updates `settings.json` to remove the `icon` property for the `NixOS` profile.

7. **Cleanup**

   * Deletes the downloaded `nixos.wsl` file.

8. **Restart WSL**

   * Terminates and reopens the WSL distro to reload environment with the new user.

## Optional Tools

### WSL USB Integration

To enable USB device passthrough for WSL, you can use [WSL USB GUI](https://gitlab.com/alelec/wsl-usb-gui), an optional utility that provides a graphical interface to manage USB device forwarding into your WSL distributions.

- GitLab Repository: [wsl-usb-gui](https://gitlab.com/alelec/wsl-usb-gui)
- Download the latest version from the [Releases Page](https://gitlab.com/alelec/wsl-usb-gui/-/releases)

This tool can be useful if you need access to USB peripherals (e.g., serial devices, USB drives) within your NixOS WSL environment.

