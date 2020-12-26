
# Speakers automatically switch off after 20 minutes when not in use, when sold in the European Union,
# cf European Commission Regulation (EC) No 1275/2008, and (EU) No 801/2013.

# This script is keeping the speakers on by playing an inaudible sound every 10 minutes.

# Windows > cmd > Run as administrator
# cd [...]
# ./keep_speakers_alive.ps1

$TaskName   = "keep_speakers_alive"
$ScriptPath = "C:\Windows\Temp\keep_speakers_alive.vbs" # this VB script will be created
$SoundPath  = "C:\Windows\Temp\22000.wav" # this sound file will be created
$SoundURL   = "https://github.com/jeannier/keep-speakers-alive/raw/main/22000.wav" # sound to download
$Duration   = "P1D" # the task will be scheduled every day
$Interval   = "PT10M" # the task will run every 10 minutes

# sound file

if (Test-Path $SoundPath) {
  "deleting pre-existing sound file"
  Remove-Item $SoundPath
} else {
  "sound file doesnt exist yet"
}

"downloading sound file"
Invoke-WebRequest $SoundURL -OutFile $SoundPath

# script file

if (Test-Path $ScriptPath) {
  "deleting pre-existing script"
  Remove-Item $ScriptPath
} else {
  "script doesnt exist yet"
}

"creating script file"
$scriptContent = "CreateObject(`"Wscript.Shell`").Run `"wmplayer /play /close `"`"$SoundPath`"`"`", 0, False"
New-Item $ScriptPath -Type File  | Out-Null
Set-Content -Path $ScriptPath -Value $scriptContent

# scheduled task

$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $TaskName }
if($taskExists) {
  "deleting pre-existing scheduled task"
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
} else {
  "scheduled task doesnt exist yet"
}

"creating scheduled task"
$Action = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument $ScriptPath
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Task = Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action
$Task.Triggers.Repetition.Duration = $Duration
$Task.Triggers.Repetition.Interval = $Interval
$Task | Set-ScheduledTask | Out-Null

"starting scheduled task"
Start-ScheduledTask -TaskName $TaskName

"all done"
