# Function to determine if a user is logged in
function IsUserLoggedIn {
    $loggedInUsers = quser
    return ($loggedInUsers -match "active")
}

# Function to log messages to a file
function LogMessage($message) {
    try {
        $logFilePath = "C:\RebootLog.txt"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $logFilePath -Value "$timestamp - $message"
    } catch {
        Write-Host "Error occurred while logging message: $_"
    }
}

# Function to log results to a file
function LogResult($message) {
    LogMessage $message
}

# Check if a reboot is required and handle accordingly
function CheckAndHandleReboot {
    # Log the start of the reboot check
    LogMessage "Starting check for reboot..."

    # For automation, assume we want to reboot
    $result = $true
    if ($result) {
        # Decision to reboot
        LogResult "Automation decided to reboot. Proceeding with reboot..."
        Restart-Computer -Force
        return $false
    } else {
        # Decision to defer reboot (not typically used in automation)
        LogResult "Automation deferred reboot."
        return $true
    }
}

# Main script logic
if (IsUserLoggedIn) {
    # User is logged in, prompt for reboot if needed
    $RePromptInterval = 60  # in seconds (default: 1 minute)

    $rebootRequired = $true
    while ($rebootRequired) {
        $rebootRequired = CheckAndHandleReboot
        if ($rebootRequired) {
            Start-Sleep -Seconds $RePromptInterval
        }
    }
} else {
    # No user is logged in, reboot the machine
    LogResult "No user is logged in. Rebooting the machine..."
    Restart-Computer -Force
}
