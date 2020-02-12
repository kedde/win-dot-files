$location = Get-location
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$user = "$username"
$autoHoykeyConfigFile = "`"$location\AutoHotkey.ahk`""
write-host $user 'AUTO' $autoHoykeyConfigFile

$action = New-ScheduledTaskAction -Execute '"C:\Program Files\AutoHotkey\AutoHotkey.exe"' -Argument $autoHoykeyConfigFile

# $trigger =  New-ScheduledTaskTrigger -Daily -At 9am

# $trigger =  New-ScheduledTaskTrigger –AtStartup # -RandomDelay 00:00:30
$trigger = New-ScheduledTaskTrigger -AtLogOn



Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "AutohotKey" -Description "Starts the autohotkey on startup" -User $user -RunLevel Highest