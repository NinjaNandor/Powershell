function Get-ProfileList {
    $PatternSID = 'S-1-(2|12|5)-(0|1|21)\-\d+-\d+\-\d+\-\d+$'
    return Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' |
        Where-Object { $_.PSChildName -match $PatternSID } |
        Select-Object @{
            Name = "SID";
            Expression = { $_.PSChildName }
        }, @{
            Name = "UserHive";
            Expression = { "$($_.ProfileImagePath)\ntuser.dat" }
        }, @{
            Name = "Username";
            Expression = { $_.ProfileImagePath -replace '^(.*[\\\/])', '' }
        }
}

function Get-LoadedHives {
    $PatternSID = 'S-1-(2|12|5)-(0|1|21)\-\d+-\d+\-\d+\-\d+$'
    return Get-ChildItem Registry::HKEY_USERS |
        Where-Object { $_.PSChildname -match $PatternSID } |
        Select-Object @{
            Name = "SID";
            Expression = { $_.PSChildName }
        }
}

function Load-UnloadedHives {
    param (
        [array]$ProfileList,
        [array]$LoadedHives
    )

    if ($LoadedHives -eq $null) {
        return $ProfileList | Select-Object SID, UserHive, Username
    } else {
        return Compare-Object $ProfileList.SID $LoadedHives.SID |
            Select-Object @{ Name = "SID"; Expression = { $_.InputObject } }, UserHive, Username
    }
}

function Get-MappedDrives {
    param (
        [array]$ProfileList,
        [array]$UnloadedHives
    )

    $MappedDrives = [System.Collections.Generic.List[Object]]::New()

    foreach ($Profile in $ProfileList) {
        if ($Profile.SID -in $UnloadedHives.SID) {
            reg load HKU\$($Profile.SID) $($Profile.UserHive) | Out-Null
        }

        if (Test-Path "Registry::HKEY_USERS\$($Profile.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2") {
            $MountPoints = Get-ChildItem -Path "Registry::HKEY_USERS\$($Profile.SID)\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2" |
                Where-Object { $_.Name -like "*##*" }

            foreach ($MountPoint in $MountPoints) {
                $Path = $MountPoint.Name.Replace('#', '\')
                [void]$MappedDrives.Add([PSCustomObject]@{
                    Key  = $MountPoint.PSPath.Substring($MountPoint.PSPath.IndexOf('HKEY'))
                    Path = $Path.Substring($Path.LastIndexOf("\"))
                    User = $Profile.Username
                })
            }
        }

        if ($Profile.SID -in $UnloadedHives.SID) {
            [gc]::Collect()
            reg unload HKU\$($Profile.SID) | Out-Null
        }
    }

    return $MappedDrives
}

$ProfileList = Get-ProfileList
$LoadedHives = Get-LoadedHives
$UnloadedHives = Load-UnloadedHives -ProfileList $ProfileList -LoadedHives $LoadedHives
$MappedDrives = Get-MappedDrives -ProfileList $ProfileList -UnloadedHives $UnloadedHives

Ninja-Property-Set manuallymappeddrives ($MappedDrives | Format-List | Out-String)
$MappedDrives | Format-List
