$location = Get-location
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$user = "$username"
$autoHoykeyConfigFile = "`"$location\AutoHotkey.ahk`""
write-host $user 'AUTO' $autoHoykeyConfigFile

# \scoop\apps\autohotkey\current\AutoHotkeyU64.exe
$executable = scoop which autohotkey
Write-host "setting the executable to $executable"
# "C:\Program Files\AutoHotkey\AutoHotkey.exe"
$action = New-ScheduledTaskAction -Execute $executable -Argument $autoHoykeyConfigFile

# $trigger =  New-ScheduledTaskTrigger -Daily -At 9am

# $trigger =  New-ScheduledTaskTrigger –AtStartup # -RandomDelay 00:00:30
$trigger = New-ScheduledTaskTrigger -AtLogOn



Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AutohotKey" -Description "Starts the autohotkey on startup" -User $user -RunLevel Highest
