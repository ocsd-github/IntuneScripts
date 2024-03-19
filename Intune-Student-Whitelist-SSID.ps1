# Define the log file path
$LogFilePath = "C:\Temp\SSIDProfileDeletionLog.txt"


# Ensure the log file directory exists
$LogDirectory = Split-Path -Path $LogFilePath -Parent
if (-not (Test-Path -Path $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Ignore
    New-Item -ItemType File -Path $LogFilePath -Ignore
}


# Helper function for logging
function Log-Message {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "${Timestamp}: $Message" | Out-File -FilePath $LogFilePath -Append
}


# Log script start
Log-Message "Script started."


# Define the allowed SSIDs
$allowedSSIDs = @("OCSD", "iOCSD", "OCSD_Guest")


# Get the list of all wireless network profiles
$profiles = netsh wlan show profiles | Select-String -Pattern "All User Profile" | ForEach-Object {
    $_ -replace "^.*:\s*", ""
}


# Loop through the profiles and remove those not in the allowed list
foreach ($profile in $profiles) {
    if ($profile -notin $allowedSSIDs) {
        # Remove the unwanted profile
        netsh wlan delete profile name="$profile"
        Write-Host "Removed profile: $profile"
        Log-Message "Removed profile: $profile"
    }
    else {
        Write-Host "Keeping profile: $profile"
        Log-Message "Keeping profile: $profile"
    }
}


# Log script end
Log-Message "Script stopped."