# Simple Windows Software Installer
# Designed for maximum compatibility with Boxstarter

# Disable progress bars to avoid parsing issues
$ProgressPreference = 'SilentlyContinue'

Write-Host "=== WINDOWS SOFTWARE INSTALLER ===" -ForegroundColor Green
Write-Host "This script will install essential software packages" -ForegroundColor Cyan
Write-Host ""

# Install core system tools
Write-Host "Installing system tools..." -ForegroundColor Yellow
choco install 7zip -y
choco install notepadplusplus -y
choco install git -y

# Install browsers
Write-Host "Installing browsers..." -ForegroundColor Yellow
choco install googlechrome -y
choco install firefox -y

# Install media and communication tools
Write-Host "Installing media and communication tools..." -ForegroundColor Yellow
choco install vlc -y
choco install discord -y

# Install development tools
Write-Host "Installing development tools..." -ForegroundColor Yellow
choco install vscode -y
choco install python3 -y

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "You may need to restart your computer for changes to take effect." -ForegroundColor Cyan
