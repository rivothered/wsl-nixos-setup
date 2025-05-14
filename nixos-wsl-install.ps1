# GitHub repository
$repo = "nix-community/NixOS-WSL"

# Custom name for the WSL distribution
$distroName = "NixOS"

# Installation directory for the distribution
$installLocation = "$env:USERPROFILE\WSL\$distroName"

# Local path to save the nixos.wsl file
$outputFile = "$PWD\nixos.wsl"

# GitHub API URL for the latest release
$apiUrl = "https://api.github.com/repos/$repo/releases/latest"

# Header required by GitHub API
$headers = @{ "User-Agent" = "PowerShell" }

# Prompt for new user details
$newUsername = Read-Host "Enter the name of the new user to create in NixOS"
$newPassword = Read-Host "Enter the password for the new user" -AsSecureString
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword)
)

# Fetch the latest release data
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers

# Look for the asset named 'nixos.wsl'
$asset = $response.assets | Where-Object { $_.name -eq "nixos.wsl" }

if ($asset -ne $null) {
    $downloadUrl = $asset.browser_download_url

    Write-Output "Downloading: $downloadUrl"
    Start-BitsTransfer -Source $downloadUrl -Destination $outputFile
    Write-Output "Download completed: $outputFile"

    # Check if the distribution is already registered
    $existingDistros = wsl --list --quiet
    if ($existingDistros -contains $distroName) {
        Write-Warning "The distribution '$distroName' is already registered in WSL."
    } else {
        # Create the installation directory if it doesn't exist
        if (-not (Test-Path -Path $installLocation)) {
            New-Item -ItemType Directory -Path $installLocation | Out-Null
        }

        Write-Output "Registering distribution '$distroName' in WSL..."
        wsl --import $distroName $installLocation $outputFile --version 2
        Write-Output "Distribution '$distroName' registered successfully!"
    }

    # Step 1: Create new user
    Write-Output "Creating new user '$newUsername'..."
    $createUserCmd = @"
useradd -m -G wheel $newUsername && echo "${newUsername}:${plainPassword}" | sudo chpasswd
"@
    wsl -d $distroName -u root -- sh -c $createUserCmd

    # Step 2: Update default user in configuration.nix
    Write-Output "Updating default WSL user to '$newUsername' in configuration.nix..."
    $setDefaultUserCmd = @"
sed -i 's|wsl\.defaultUser = \".*\";|wsl.defaultUser = \"$newUsername\";|' /etc/nixos/configuration.nix
"@
    wsl -d $distroName -u root -- sh -c $setDefaultUserCmd

    # Step 3: Download devtools.nix and update configuration.nix to include it
    Write-Output "Downloading devtools.nix and updating configuration.nix..."
    $addDevtoolsCmd = @"
curl -o /etc/nixos/devtools.nix https://raw.githubusercontent.com/rivothered/wsl-nixos-setup/refs/heads/main/devtools.nix &&
sed -i '/<nixos-wsl\\/modules>/a \  ./devtools.nix' /etc/nixos/configuration.nix
"@
    wsl -d $distroName -u root -- sh -c $addDevtoolsCmd

    # Step 4: Update configuration.nix and run nixos-rebuild
    Write-Output "Updating NixOS channels and rebuilding the system..."
    wsl -d $distroName -u root -- sh -c "nix-channel --update && nixos-rebuild switch"

    # Step 5: Remove NixOS icon from Windows Terminal
    # Current version of NixOS doesn't have a icon, causing a warning on Windows Terminal
    Write-Output "Removing icon from NixOS profile in Windows Terminal..."
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path -Path $settingsPath) {
        try {
            $settingsContent = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

            foreach ($profile in $settingsContent.profiles.list) {
                if ($profile.name -eq "NixOS") {
                    if(-not ($profile.PSObject.Properties["icon"])) {
                        $profile | Add-Member -MemberType NoteProperty -Name "icon" -Value "none"
                    } else {
                        $profile.icon = "none"
                    }
                    Write-Output "Icon property for 'NixOS' cleared."
                }
            }

            $settingsContent | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8
        } catch {
            Write-Warning "Failed to update Windows Terminal settings: $_"
        }
    } else {
        Write-Warning "Windows Terminal settings file not found. Skipping icon removal."
    }

    # Step 6: Cleanup - remove the nixos.wsl file
    Write-Output "Cleaning up by removing the 'nixos.wsl' file..."
    Remove-Item -Path $outputFile -Force
    Write-Output "'nixos.wsl' file removed successfully."

    # Step 7: Restart the WSL distro
    Write-Output "Restarting WSL distro '$distroName' to apply all changes..."
    wsl -t $distroName
    Start-Sleep -Seconds 2
    wsl -d $distroName
} else {
    Write-Error "File 'nixos.wsl' not found in the latest release."
}
