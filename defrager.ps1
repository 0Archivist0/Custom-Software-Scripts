# Author: Kris Tomplait
# This script was wrote by me so use it at your own risk

# Function to check if a command is available
function Test-Command($command) {
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

# Function to run a command as administrator
function Run-CommandAsAdmin($command) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $command
    $psi.Verb = "runas"
    [System.Diagnostics.Process]::Start($psi) | Out-Null
}

# Check if running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Prompt to run as administrator if not already elevated
if (-not $isAdmin) {
    $response = [System.Windows.Forms.MessageBox]::Show("This script requires administrator privileges.`nDo you want to run it as administrator?", "Run as Administrator", "YesNo", "Warning")

    if ($response -eq "Yes") {
        # Relaunch the script with elevated permissions
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    } else {
        Write-Output "Script execution canceled."
        exit 1
    }
}

# Check if the necessary commands are available
$defragCommand = "Optimize-Volume"
$clearTrashCommand = "cleanmgr"

if (-not (Test-Command $defragCommand) -or -not (Test-Command $clearTrashCommand)) {
    Write-Output "Defragmentation, optimization, or trash cleaning commands are not available on this system."
    exit 1
}

# Automate defragmentation and optimization
try {
    Write-Output "Running defragmentation and optimization..."
    Optimize-Volume -DriveLetter C -Defrag -Verbose
    Write-Output "Defragmentation and optimization completed successfully."
}
catch {
    Write-Output "Error during defragmentation and optimization: $_"
    exit 1
}

# Automate trash cleaning using cleanmgr
try {
    Write-Output "Running trash cleaning..."
    Run-CommandAsAdmin "cleanmgr.exe /sagerun:1"
    Write-Output "Trash cleaning completed successfully."
}
catch {
    Write-Output "Error during trash cleaning: $_"
    exit 1
}

# Additional feature: Check for updates and install them if available
try {
    Write-Output "Checking for system updates..."
    Start-Process wusa.exe -ArgumentList " /update now" -Verb RunAs
    Write-Output "System update check completed successfully."
}
catch {
    Write-Output "Error checking for system updates: $_"
    # Consider adding an exit statement here if it's a critical error
}

Write-Output "Script completed successfully."
