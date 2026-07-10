$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScheduleFile = Join-Path $ScriptDir "schedule.json"
$LogFile = Join-Path $ScriptDir "run.log"
$StartHour = 8
$EndHour = 20

function Write-Log([string]$Message) {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Save-Schedule([hashtable]$Schedule) {
    $Schedule | ConvertTo-Json | Set-Content -Path $ScheduleFile -Encoding UTF8
}

function Load-Schedule {
    if (-not (Test-Path $ScheduleFile)) { return $null }
    try {
        return Get-Content $ScheduleFile -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        return $null
    }
}

function New-TodaySchedule([DateTime]$Day) {
    $dayStart = $Day.Date.AddHours($StartHour)
    $dayEnd = $Day.Date.AddHours($EndHour)
    $totalMinutes = [int]($dayEnd - $dayStart).TotalMinutes
    $count = Get-Random -Minimum 3 -Maximum 9

    $times = @()
    for ($i = 0; $i -lt $count; $i++) {
        $offset = Get-Random -Minimum 0 -Maximum ($totalMinutes + 1)
        $times += $dayStart.AddMinutes($offset).ToString("HH:mm")
    }

    $times = $times | Sort-Object -Unique

    return @{
        date      = $Day.ToString("yyyy-MM-dd")
        times     = @($times)
        committed = @()
    }
}

function Get-TodaySchedule {
    $today = (Get-Date).ToString("yyyy-MM-dd")
    $existing = Load-Schedule

    if ($existing -and $existing.date -eq $today) {
        return @{
            date      = $existing.date
            times     = @($existing.times)
            committed = @($existing.committed)
        }
    }

    return (New-TodaySchedule (Get-Date))
}

function Parse-ScheduleTime([string]$Date, [string]$Time) {
    return [DateTime]::ParseExact("$Date $Time", "yyyy-MM-dd HH:mm", $null)
}

function Invoke-ScanCommit {
    param([hashtable]$Schedule)

    $now = Get-Date
    $pending = @()

    foreach ($time in $Schedule.times) {
        if ($Schedule.committed -contains $time) { continue }
        $planned = Parse-ScheduleTime $Schedule.date $time
        if ($now -ge $planned) {
            $pending += $time
        }
    }

    if ($pending.Count -eq 0) {
        return $Schedule
    }

    $latest = ($pending | ForEach-Object { Parse-ScheduleTime $Schedule.date $_ } | Sort-Object | Select-Object -Last 1)
    $latestStr = $latest.ToString("HH:mm")

    if ($pending.Count -gt 1) {
        $skipped = $pending[0..($pending.Count - 2)] -join ', '
        Write-Log "Missed $($pending.Count) slots, commit latest only: $latestStr (skip $skipped)"
    } else {
        Write-Log "Due at $latestStr, committing now"
    }

    foreach ($time in $pending) {
        if (Parse-ScheduleTime $Schedule.date $time -le $latest) {
            if ($Schedule.committed -notcontains $time) {
                $Schedule.committed += $time
            }
        }
    }

    Save-Schedule $Schedule

    $commitScript = Join-Path $ScriptDir "auto-commit.bat"
    & cmd.exe /c $commitScript 2>&1 | ForEach-Object { Write-Log $_ }

    return $Schedule
}

Set-Location $ScriptDir

$dayStart = (Get-Date).Date.AddHours($StartHour)
$dayEnd = (Get-Date).Date.AddHours($EndHour)
$now = Get-Date

if ($now -lt $dayStart) {
    Write-Log "Before ${StartHour}:00, skip scan"
    exit 0
}

if ($now -ge $dayEnd) {
    Write-Log "Past ${EndHour}:00, skip scan"
    exit 0
}

$schedule = Get-TodaySchedule
$existing = Load-Schedule
if (-not $existing -or $existing.date -ne $schedule.date) {
    Save-Schedule $schedule
    Write-Log "New schedule ($($schedule.times.Count)): $($schedule.times -join ', ')"
}

Write-Log "Scan at $($now.ToString('HH:mm:ss'))"
$schedule = Invoke-ScanCommit $schedule
Write-Log "Progress: $($schedule.committed.Count)/$($schedule.times.Count) done"
