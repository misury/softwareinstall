# Windows Software Installer - Full Version
# Compatible with Boxstarter

# Check for administrator privileges
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

Write-Host "=== WINDOWS SOFTWARE INSTALLER ===" -ForegroundColor Green
Write-Host "Installing essential software packages..." -ForegroundColor Cyan

# System Tools
Write-Host "Installing System Tools..." -ForegroundColor Yellow
choco install 7zip -y --no-progress
choco install winrar -y --no-progress
choco install notepadplusplus -y --no-progress
choco install curl -y --no-progress
choco install git -y --no-progress
choco install wget -y --no-progress
choco install unzip -y --no-progress
choco install tailscale -y --no-progress

# Browsers
Write-Host "Installing Browsers..." -ForegroundColor Yellow
choco install googlechrome -y --no-progress
choco install firefox -y --no-progress

# NVIDIA Drivers
Write-Host "Installing NVIDIA Drivers..." -ForegroundColor Yellow
choco install geforce-experience -y --no-progress
choco install nvidia-display-driver -y --no-progress

# Disk Utilities
Write-Host "Installing Disk Utilities..." -ForegroundColor Yellow
choco install etcher -y --no-progress
choco install rufus -y --no-progress
choco install rpi-imager -y --no-progress

# Media and Communication
Write-Host "Installing Media & Communication..." -ForegroundColor Yellow
choco install vlc -y --no-progress
choco install steam -y --no-progress
choco install discord -y --no-progress
choco install signal -y --no-progress
choco install heroic-games-launcher -y --no-progress

# Development Tools
Write-Host "Installing Development Tools..." -ForegroundColor Yellow
choco install python3 -y --no-progress
choco install nodejs -y --no-progress
choco install powershell -y --no-progress
choco install visualstudio2022community -y --no-progress
choco install vscode -y --no-progress

# SSH Tools
Write-Host "Installing SSH Tools..." -ForegroundColor Yellow
choco install bitvise-ssh-client -y --no-progress

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "You may need to restart your computer for changes to take effect." -ForegroundColor Cyan
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
