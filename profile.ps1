# Requirements:
# posh-git

# Linux fixes
if(!$env:COMPUTERNAME) {
    $env:COMPUTERNAME = hostname
}
$env:COMPUTERNAME = $env:COMPUTERNAME.ToUpper()

function prompt {
    switch (Get-Date -Format hh) {
        '00' { $ClockEmoji = '🕛'}
        '01' { $ClockEmoji = '🕐'}
        '02' { $ClockEmoji = '🕑'}
        '03' { $ClockEmoji = '🕒'}
        '04' { $ClockEmoji = '🕓'}
        '05' { $ClockEmoji = '🕔'}
        '06' { $ClockEmoji = '🕕'}
        '07' { $ClockEmoji = '🕖'}
        '08' { $ClockEmoji = '🕗'}
        '09' { $ClockEmoji = '🕘'}
        '10' { $ClockEmoji = '🕙'}
        '11' { $ClockEmoji = '🕚'}
    }
    Write-Host "$($ClockEmoji)$(Get-Date -Format HH:mm)" -NoNewline -BackgroundColor Magenta -ForegroundColor Black
    Write-Host " " -NoNewline

    $Temp = Get-ChildItem /sys/class/thermal/thermal_zone*/temp | Get-Content
    [int]$Temp = ($Temp | Measure-Object -Average).Average/1000

    Write-Host "🧔$env:USERNAME@💻$env:COMPUTERNAME" -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host " " -NoNewline

    $BatPercent = (upower -i "/org/freedesktop/UPower/devices/DisplayDevice" | Select-String -Pattern '\d{1,3}.*%').Matches.Value
    $BatInt = $BatPercent.Split('.')[0]

    Write-Host "🔋$BatInt%" -BackgroundColor Blue -NoNewline -ForegroundColor Black
    Write-Host " " -NoNewline
    
    $TempColor = "Green"
    if($Temp -ge 50) {$TempColor = "Yellow"}
    if($Temp -ge 65) {$TempColor = "Red"}
    Write-Host "🔥$Temp°C" -BackgroundColor $TempColor -ForegroundColor Black -NoNewline
    Write-Host " " -NoNewline

    $ParentPath = Split-Path $PWD.Path -Parent
    $LeafPath = Split-Path $PWD.Path -Leaf
    Write-Host "📁$ParentPath/" -NoNewline -BackgroundColor DarkBlue -ForegroundColor White
    Write-Host $LeafPath -NoNewline -BackgroundColor DarkBlue 
    Write-Host " " -NoNewline

    $GitStatus = Get-GitStatus
    if($GitStatus) {
        $Changes = $GitStatus.AheadBy + $GitStatus.BehindBy + $GitStatus.Working.Count
        if($Changes -eq 0) {
            Write-Host "$($GitStatus.Branch)" -BackgroundColor Green -ForegroundColor Black -NoNewline
        }
        else {
            Write-Host "$($GitStatus.Branch) $Changes" -BackgroundColor Yellow -ForegroundColor Black -NoNewline
        }
        Write-Host " " -NoNewline
    }

    $RunningContainers = (docker ps | Measure-Object).Count -1 # Remove table header
    if($RunningContainers -gt 0) {
        Write-Host "🐋$RunningContainers" -NoNewline -BackgroundColor Green -ForegroundColor Black
        Write-Host " "
    }

    return "pwsh> "

}

# Aliased
New-Alias -Name celar -Value "Clear-Host" # Typo for "clear"