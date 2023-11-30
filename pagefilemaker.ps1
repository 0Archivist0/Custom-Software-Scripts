 # Check if a paging file exists
$pagingFileExists = Get-PageFile | Where-Object { $_.Path -like '*\pagefile.sys' }

# If a paging file exists, prompt the user for action
if ($pagingFileExists) {
    $overwrite = Read-Host "A paging file already exists. Do you want to overwrite it? (Y/N)"
    
    if ($overwrite -eq 'Y') {
        try {
            Remove-PageFile -Path "C:\pagefile.sys" -ErrorAction Stop
            Write-Output "Existing paging file removed."
        }
        catch {
            Write-Output "Error removing the existing paging file: $_"
            exit 1
        }
    }
    else {
        Write-Output "Exiting..."
        exit
    }
}

# Prompt the user for the size of the paging file in gigabytes
do {
    $pagingFileSizeGB = Read-Host "Enter the desired paging file size in gigabytes (e.g., 4 for a 4GB paging file):"
    
    # Validate the user input
    if (-not [int]::TryParse($pagingFileSizeGB, [ref]$null) -or $pagingFileSizeGB -lt 1) {
        Write-Output "Please enter a valid positive integer for the paging file size."
    }
} while (-not ([int]::TryParse($pagingFileSizeGB, [ref]$null) -and $pagingFileSizeGB -ge 1))

# Convert the user input to megabytes
$pagingFileSizeMB = $pagingFileSizeGB * 1024

# Attempt to create the paging file with error handling
try {
    New-PageFile -Path "C:\pagefile.sys" -SizeInBytes $pagingFileSizeMB -ErrorAction Stop
    Write-Output "Paging file created successfully."
}
catch {
    Write-Output "Error creating the paging file: $_"
    exit 1
}

# Set the paging file to be permanent
try {
    Set-PageFile -Automatic $true -ErrorAction Stop
    Write-Output "Paging file set to be permanent."
}
catch {
    Write-Output "Error setting the paging file to be permanent: $_"
    exit 1
}
