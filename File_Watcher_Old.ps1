# Folder monitoring tool for file activity
# Credits: code made by QXJ6YW4gRWxjaGlkYW5h with reference from Adam Bertram
# 
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.IncludeSubdirectories = $true
$watcher.Path = Read-Host "Enter the path"
$watcher | Get-Member -MemberType Event -Force
$watcher.EnableRaisingEvents = $true
$action =
{
    $path = $event.SourceEventArgs.FullPath
    $name = $event.SourceEventArgs.Name
    $changetype = $event.SourceEventArgs.ChangeType
    Write-Host "File $name at path $path was $changetype at $(get-date)"
}
Register-ObjectEvent $watcher 'Created' -Action $action
Register-ObjectEvent $watcher 'Deleted' -Action $action
Register-ObjectEvent $watcher 'Renamed' -Action $action
Register-ObjectEvent $watcher 'Disposed' -Action $action
Register-ObjectEvent $watcher 'Changed' -Action $action
Register-ObjectEvent $watcher 'Error' -Action $action
