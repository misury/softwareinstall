# Windows Software Installer Script
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

# Define the software packages to install
$softwarePackages = @(
    # System Tools
    @{Name = "7zip"; Category = "System Tools"},
    @{Name = "notepadplusplus"; Category = "System Tools"},
    @{Name = "git"; Category = "System Tools"},
    @{Name = "wget"; Category = "System Tools"},
    # Browsers
    @{Name = "googlechrome"; Category = "Browsers"},
    @{Name = "firefox"; Category = "Browsers"},
    # Utilities
    @{Name = "vlc"; Category = "Media"},
    @{Name = "discord"; Category = "Communication"},
    @{Name = "steam"; Category = "Gaming"},
    # Dev Tools
    @{Name = "python3"; Category = "Development"},
    @{Name = "nodejs"; Category = "Development"},
    @{Name = "vscode"; Category = "Development"}
)

# Installation function with better error handling
function Install-Software {
    param (
        [string]$PackageName,
        [string]$Category
    )
    
    Write-Host "Installing $PackageName ($Category)..." -ForegroundColor Cyan
    
    try {
        # Use --no-progress to avoid parsing issues in Boxstarter
        $chocoArgs = @("install", $PackageName, "-y", "--no-progress")
        & choco $chocoArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Successfully installed $PackageName" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Failed to install $PackageName (Exit code: $LASTEXITCODE)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "✗ Error installing $PackageName: $_" -ForegroundColor Red
        return $false
    }
}

# Main installation loop
function Start-Installation {
    $successful = 0
    $failed = 0
    
    Write-Host ""
    Write-Host "Starting software installation..." -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    
    foreach ($package in $softwarePackages) {
        if (Install-Software -PackageName $package.Name -Category $package.Category) {
            $successful++
        } else {
            $failed++
        }
    }
    
    Write-Host ""
    Write-Host "Installation Summary:" -ForegroundColor Cyan
    Write-Host "===================="
    Write-Host "Total packages: $($softwarePackages.Count)" -ForegroundColor White
    Write-Host "Successful: $successful" -ForegroundColor Green
    Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
    
    if ($failed -gt 0) {
        Write-Host ""
        Write-Host "Some packages failed to install. You may need to install them manually." -ForegroundColor Yellow
    }
}

# Start the installation
Write-Host "=================================" -ForegroundColor Green
Write-Host "   WINDOWS SOFTWARE INSTALLER    " -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""
Write-Host "This script will install several useful software packages using Chocolatey."
Write-Host "Press any key to start installation or Ctrl+C to cancel..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Start-Installation

Write-Host ""
Write-Host "Installation process complete!" -ForegroundColor Green
Write-Host "You may need to restart your computer for some changes to take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
