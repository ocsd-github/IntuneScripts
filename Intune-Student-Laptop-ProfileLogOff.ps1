# Define the log file path
$LogFilePath = "C:\Temp\InactiveProfileLogOff.txt"


# Ensure the log file directory exists
$LogDirectory = Split-Path -Path $LogFilePath -Parent
if (-not (Test-Path -Path $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Force
    New-Item -ItemType File -Path $LogFilePath -Force
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


# Get the list of logged-in users, excluding system accounts, and sorting by logon time
$loggedOnUsers = query user | Where-Object { $_ -notmatch '^(>+)?\s*SERVICES\s*$' } | Select-Object -Skip 1 | ForEach-Object {
    $fields = -split $_
    [PSCustomObject]@{
        UserName    = $fields[0]
        SessionName = $fields[1]
        Id          = $fields[2]
        State       = $fields[3]
        LogonTime   = (Get-Date -Date "$($fields[-2]) $($fields[-1])")
    }
} | Sort-Object LogonTime -Descending


# Filter out active users
$usersToLogOff = $loggedOnUsers | Where-Object {
    $_.State -ne 'Active' -and $_.Id -eq 'Disc'
}


# Determine if there are users to log off
if ($usersToLogOff) {
    # Loop through the sessions and log them off
    foreach ($session in $usersToLogOff) {
        $logMessage = "Logging off session $($session.SessionName) for user $($session.UserName) logged on at $($session.LogonTime)"
        Log-Message $logMessage
        Write-Host $logMessage
        Logoff $session.Id
    }
}
else {
    $message = "There are no users to log off based on the criteria. No action needed."
    Log-Message $message
    Write-Host $message
}


# Log script end
Log-Message "Script stopped."
