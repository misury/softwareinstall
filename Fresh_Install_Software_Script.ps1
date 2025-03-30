# Simple Windows Software Installer
# This script must be run as Administrator!

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "ERROR: This script requires administrator privileges!" -ForegroundColor Red
    Write-Host "Please close this window and run PowerShell as Administrator." -ForegroundColor Red
    Write-Host "(Right-click on PowerShell and select 'Run as Administrator')" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Set execution policy
Write-Host "Setting execution policy to Bypass for this session..." -ForegroundColor Cyan
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force
} catch {
    Write-Host "Warning: Could not set execution policy, but we'll try to continue..." -ForegroundColor Yellow
}

# Install Chocolatey if not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        # Verify installation
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            throw "Chocolatey installation failed. Please install manually."
        }
    } catch {
        Write-Host "ERROR: Failed to install Chocolatey. Error: $_" -ForegroundColor Red
        Write-Host "Please visit https://chocolatey.org/install for manual installation instructions." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
}

# Define package lists
$systemTools = @(
    "7zip",
    "winrar",
    "notepadplusplus.install",
    "curl",
    "git",
    "wget",
    "unzip",
    "tailscale"
)

$browsers = @(
    "googlechrome",
    "firefox"
)

$nvidiaDrivers = @(
    "geforce-experience",
    "nvidia-display-driver"
)

$diskUtilities = @(
    "etcher",
    "rufus",
    "rpi-imager"
)

$mediaAndGaming = @(
    "vlc",
    "steam",
    "discord",
    "signal",
    "heroic-games-launcher"
)

$developmentTools = @(
    "python3",
    "nodejs",
    "powershell",
    "visualstudio2022community"
)

$sshTools = @(
    "bitvise-ssh-client"
)

# Show menu
function Show-Menu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "           WINDOWS SOFTWARE INSTALLER             " -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Select an option:" -ForegroundColor Cyan
    Write-Host "1. Install everything (all software)" -ForegroundColor White
    Write-Host "2. Select categories to install" -ForegroundColor White
    Write-Host "3. Create offline installer (download only)" -ForegroundColor White
    Write-Host "4. Install from offline repository" -ForegroundColor White
    Write-Host "5. Exit" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-5)"
    return $choice
}

# Function to install packages
function Install-Packages {
    param (
        [string[]]$packages,
        [string]$category,
        [string]$source = "https://community.chocolatey.org/api/v2/"
    )
    
    Write-Host "Installing $category..." -ForegroundColor Cyan
    foreach ($package in $packages) {
        Write-Host "  Installing $package..." -ForegroundColor White
        try {
            if ($source -eq "https://community.chocolatey.org/api/v2/") {
                choco install $package -y
            } else {
                choco install $package --source="'$source;https://community.chocolatey.org/api/v2/'" -y
            }
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  Warning: $package installation may have had issues." -ForegroundColor Yellow
            } else {
                Write-Host "  Successfully installed $package." -ForegroundColor Green
            }
        } catch {
            Write-Host "  Error installing $package: $_" -ForegroundColor Red
        }
    }
}

# Function to download packages
function Download-Packages {
    param (
        [string[]]$packages,
        [string]$category,
        [string]$destination
    )
    
    Write-Host "Downloading $category packages..." -ForegroundColor Cyan
    foreach ($package in $packages) {
        Write-Host "  Downloading $package..." -ForegroundColor White
        try {
            choco download $package --source="'https://community.chocolatey.org/api/v2/'" --output-directory="'$destination'" --ignore-dependencies
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  Warning: $package download may have had issues." -ForegroundColor Yellow
            } else {
                Write-Host "  Successfully downloaded $package." -ForegroundColor Green
            }
        } catch {
            Write-Host "  Error downloading $package: $_" -ForegroundColor Red
        }
    }
}

# Function to select folder
function Select-Folder {
    param (
        [string]$description = "Select folder",
        [string]$defaultPath = "C:\ChocolateyLocalRepo"
    )
    
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = $description
    $folderBrowser.RootFolder = "MyComputer"
    $folderBrowser.SelectedPath = $defaultPath
    
    $result = $folderBrowser.ShowDialog()
    
    if ($result -eq "OK") {
        return $folderBrowser.SelectedPath
    } else {
        return $null
    }
}

# Function to select categories
function Select-Categories {
    $categories = @()
    
    Write-Host "Select categories to install (enter Y/N for each):" -ForegroundColor Cyan
    
    $response = Read-Host "System Tools (7zip, WinRAR, Notepad++, etc.) [Y/N]"
    if ($response.ToUpper() -eq "Y") { $categories += "SystemTools" }
    
    $response = Read-Host "Browsers (Chrome, Firefox) [Y/N]"
    if ($response.ToUpper() -eq "Y") { $categories += "Browsers" }
    
    $response = Read-Host "NVIDIA Drivers [Y/N]"
    if ($response.ToUpper() -eq "Y") { $categories += "NvidiaDrivers" }
    
    $response = Read-Host "Disk Utilities (Etcher, Rufus, Raspberry Pi Imager) [Y/N]"
    if ($response.ToUpper() -eq "Y") { $categories += "DiskUtilities" }
    
    $response = Read-Host "Media & Communication (VLC, Steam, Discord, Signal) [Y/N]"
    if ($response.ToUpper() -eq "Y") { $categories += "MediaAndGaming" }
    
    $response = Read-Host "Development Tools (Visual Studio, Python, Node.js, PowerShell) [Y/N]"
    if ($response.ToUpper() -eq "Y") { $categories += "DevelopmentTools" }
    
    $response = Read-Host "SSH Tools (Bitvise) [Y/N]"
    if ($response.ToUpper() -eq "Y") { $categories += "SSHTools" }
    
    return $categories
}

# Create helper script for installation
function Create-InstallScript {
    param (
        [string]$repoDir
    )
    
    $installScriptPath = "$repoDir\install-software.ps1"
    
    @"
# Windows Software Installation Script - Run as Administrator

# Check if running as administrator
`$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not `$isAdmin) {
    Write-Host "ERROR: This script requires administrator privileges!" -ForegroundColor Red
    Write-Host "Please close this window and run PowerShell as Administrator." -ForegroundColor Red
    Write-Host "(Right-click on PowerShell and select 'Run as Administrator')" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..."
    `$null = `$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# Get repository location
function Select-Folder {
    param (
        [string]`$description = "Select folder",
        [string]`$defaultPath = "$repoDir"
    )
    
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    `$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    `$folderBrowser.Description = `$description
    `$folderBrowser.RootFolder = "MyComputer"
    `$folderBrowser.SelectedPath = `$defaultPath
    
    `$result = `$folderBrowser.ShowDialog()
    
    if (`$result -eq "OK") {
        return `$folderBrowser.SelectedPath
    } else {
        return `$null
    }
}

`$repoDir = Select-Folder -description "Select the folder with downloaded packages" -defaultPath "$repoDir"

if (`$null -eq `$repoDir) {
    Write-Host "No folder selected. Exiting..."
    exit
}

if (-not (Test-Path `$repoDir)) {
    Write-Host "Error: The selected directory does not exist." -ForegroundColor Red
    exit
}

# Install Chocolatey if not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment variables
        `$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        # Verify installation
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            throw "Chocolatey installation failed. Please install manually."
        }
    } catch {
        Write-Host "ERROR: Failed to install Chocolatey. Error: `$_" -ForegroundColor Red
        Write-Host "Please visit https://chocolatey.org/install for manual installation instructions." -ForegroundColor Yellow
        exit
    }
}

# Install packages from local repository
Write-Host "Installing packages from `$repoDir..." -ForegroundColor Cyan

`$packages = @(
    "7zip",
    "winrar",
    "notepadplusplus.install",
    "curl",
    "git",
    "wget",
    "unzip",
    "tailscale",
    "googlechrome",
    "firefox",
    "geforce-experience",
    "nvidia-display-driver",
    "etcher",
    "rufus",
    "rpi-imager",
    "bitvise-ssh-client",
    "vlc",
    "steam",
    "discord",
    "signal",
    "python3",
    "nodejs",
    "powershell",
    "visualstudio2022community",
    "heroic-games-launcher"
)

foreach (`$package in `$packages) {
    Write-Host "  Installing `$package..." -ForegroundColor White
    try {
        choco install `$package --source="'`$repoDir;https://community.chocolatey.org/api/v2/'" -y
    } catch {
        Write-Host "  Error installing `$package: `$_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Installation complete! You may need to restart your computer for some changes to take effect." -ForegroundColor Green
Write-Host "Press any key to exit..."
`$null = `$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
"@ | Out-File -FilePath $installScriptPath -Encoding utf8
    
    Write-Host "Created installation script: $installScriptPath" -ForegroundColor Green
}

# Main script execution

# Loop until user chooses to exit
$exit = $false
while (-not $exit) {
    $choice = Show-Menu
    
    switch ($choice) {
        # Install everything
        "1" {
            Write-Host "Installing all software packages..." -ForegroundColor Cyan
            
            Install-Packages -packages $systemTools -category "System Tools"
            Install-Packages -packages $browsers -category "Browsers"
            Install-Packages -packages $nvidiaDrivers -category "NVIDIA Drivers"
            Install-Packages -packages $diskUtilities -category "Disk Utilities"
            Install-Packages -packages $mediaAndGaming -category "Media & Gaming"
            Install-Packages -packages $developmentTools -category "Development Tools"
            Install-Packages -packages $sshTools -category "SSH Tools"
            
            Write-Host ""
            Write-Host "Installation complete! You may need to restart your computer for some changes to take effect." -ForegroundColor Green
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        # Select categories
        "2" {
            $selectedCategories = Select-Categories
            
            if ($selectedCategories.Count -eq 0) {
                Write-Host "No categories selected. Returning to menu..." -ForegroundColor Yellow
            } else {
                foreach ($category in $selectedCategories) {
                    switch ($category) {
                        "SystemTools" { Install-Packages -packages $systemTools -category "System Tools" }
                        "Browsers" { Install-Packages -packages $browsers -category "Browsers" }
                        "NvidiaDrivers" { Install-Packages -packages $nvidiaDrivers -category "NVIDIA Drivers" }
                        "DiskUtilities" { Install-Packages -packages $diskUtilities -category "Disk Utilities" }
                        "MediaAndGaming" { Install-Packages -packages $mediaAndGaming -category "Media & Gaming" }
                        "DevelopmentTools" { Install-Packages -packages $developmentTools -category "Development Tools" }
                        "SSHTools" { Install-Packages -packages $sshTools -category "SSH Tools" }
                    }
                }
                
                Write-Host ""
                Write-Host "Installation complete! You may need to restart your computer for some changes to take effect." -ForegroundColor Green
            }
            
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        # Create offline installer
        "3" {
            $repoDir = Select-Folder -description "Select folder to save packages" -defaultPath "C:\ChocolateyLocalRepo"
            
            if ($null -eq $repoDir) {
                Write-Host "No folder selected. Returning to menu..." -ForegroundColor Yellow
            } else {
                if (-not (Test-Path $repoDir)) {
                    Write-Host "Creating directory: $repoDir" -ForegroundColor Cyan
                    New-Item -Path $repoDir -ItemType Directory -Force | Out-Null
                }
                
                Download-Packages -packages $systemTools -category "System Tools" -destination $repoDir
                Download-Packages -packages $browsers -category "Browsers" -destination $repoDir
                Download-Packages -packages $nvidiaDrivers -category "NVIDIA Drivers" -destination $repoDir
                Download-Packages -packages $diskUtilities -category "Disk Utilities" -destination $repoDir
                Download-Packages -packages $mediaAndGaming -category "Media & Gaming" -destination $repoDir
                Download-Packages -packages $developmentTools -category "Development Tools" -destination $repoDir
                Download-Packages -packages $sshTools -category "SSH Tools" -destination $repoDir
                
                # Create helper script
                Create-InstallScript -repoDir $repoDir
                
                Write-Host ""
                Write-Host "Download complete! Packages saved to: $repoDir" -ForegroundColor Green
                Write-Host "To install on another computer, copy the entire folder and run the install-software.ps1 script." -ForegroundColor Yellow
            }
            
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        # Install from offline repository
        "4" {
            $repoDir = Select-Folder -description "Select folder with downloaded packages" -defaultPath "C:\ChocolateyLocalRepo"
            
            if ($null -eq $repoDir) {
                Write-Host "No folder selected. Returning to menu..." -ForegroundColor Yellow
            } else {
                if (-not (Test-Path $repoDir)) {
                    Write-Host "Error: The selected directory does not exist." -ForegroundColor Red
                } else {
                    Install-Packages -packages $systemTools -category "System Tools" -source $repoDir
                    Install-Packages -packages $browsers -category "Browsers" -source $repoDir
                    Install-Packages -packages $nvidiaDrivers -category "NVIDIA Drivers" -source $repoDir
                    Install-Packages -packages $diskUtilities -category "Disk Utilities" -source $repoDir
                    Install-Packages -packages $mediaAndGaming -category "Media & Gaming" -source $repoDir
                    Install-Packages -packages $developmentTools -category "Development Tools" -source $repoDir
                    Install-Packages -packages $sshTools -category "SSH Tools" -source $repoDir
                    
                    Write-Host ""
                    Write-Host "Installation complete! You may need to restart your computer for some changes to take effect." -ForegroundColor Green
                }
            }
            
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        # Exit
        "5" {
            $exit = $true
            Write-Host "Exiting script. Thank you for using the Windows Software Installer." -ForegroundColor Green
        }
        
        # Default - invalid choice
        default {
            Write-Host "Invalid choice. Please enter a number between 1 and 5." -ForegroundColor Red
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}
