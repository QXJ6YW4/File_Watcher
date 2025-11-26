# Folder monitoring tool with integrated logging setup (FIXED)
# Save this entire content as a single file (e.g., Monitor-And-Log.ps1)

# --- 1. Define the Monitoring Logic as a Function ---
function Start-FolderMonitor {
    [CmdletBinding()]
    param()

    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.IncludeSubdirectories = $true

    # Prompt for the monitoring path
    $watcher.Path = Read-Host "Enter the path to monitor"
    
    # Check if the path exists before proceeding
    if (-not (Test-Path $watcher.Path)) {
        Write-Error "Error: The path '$($watcher.Path)' does not exist."
        return
    }

    $watcher.EnableRaisingEvents = $true

    # --- ACTION BLOCK: Direct Logging (FIXED) ---
    # NOTE: $LogPath must be defined as global:LogPath to be accessible inside this block
    $action =
    {
        $path = $event.SourceEventArgs.FullPath
        $name = $event.SourceEventArgs.Name
        $changetype = $event.SourceEventArgs.ChangeType
        $logEntry = "File $name at path $path was $changetype at $(get-date)"
        
        # 1. Write the event entry to the console (Write-Host)
        Write-Host $logEntry
        
        # 2. Write directly to the log file (Add-Content is guaranteed to work)
        Add-Content -Path $global:LogPath -Value $logEntry
    }
    # ------------------------------------------------------------------

    # Registering all events
    Register-ObjectEvent $watcher 'Created' -Action $action | Out-Null
    Register-ObjectEvent $watcher 'Deleted' -Action $action | Out-Null
    Register-ObjectEvent $watcher 'Renamed' -Action $action | Out-Null
    Register-ObjectEvent $watcher 'Disposed' -Action $action | Out-Null
    Register-ObjectEvent $watcher 'Changed' -Action $action | Out-Null
    Register-ObjectEvent $watcher 'Error' -Action $action | Out-Null

    # Status messages are now written directly to the console using Write-Host
    Write-Host "--- Monitoring started at $(Get-Date) for path: $($watcher.Path) ---"
    Write-Host "Press Ctrl+C to stop."
    
    # Loop to keep the script running
    while($true) {
        Start-Sleep -Seconds 1 
    }
}


# --- 2. Logging Setup and Execution Logic (Runs when the script is executed) ---

# Get the path for the log file from the user and set it as a global variable
# This is necessary for the $action block to access it.
$global:LogPath = Read-Host "Enter the full path and filename for the activity log (e.g., C:\Logs\Activity.txt)"

# Add the 'Monitoring is ACTIVE...' message directly to the log file
Add-Content -Path $global:LogPath -Value "Monitoring is ACTIVE. Output is being saved to: $($global:LogPath)"

# Write status to the screen
Write-Host "Monitoring is ACTIVE. Output is being saved to: $($global:LogPath)"

# Execute the monitoring function using the Call Operator (&)
# Tee-Object is removed as direct logging (Add-Content) is now used.
& Start-FolderMonitor
