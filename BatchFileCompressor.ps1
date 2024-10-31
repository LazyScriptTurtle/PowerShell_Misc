function Compress-Files {
param (
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,

    [Parameter(Mandatory=$true)]
    [string]$DestinationPath,

    [Parameter(Mandatory=$true)]
    [string]$OutputPath

)

    $allFile = Get-ChildItem -Path $SourcePath -Recurse -Force -ErrorAction SilentlyContinue
    $allFileCount = $allFile.Count
    $total = 0
    function Is-FileInUse {
        param (
            [string]$filePath
        )

        try {
            $stream = [System.IO.File]::Open($filePath, 'Open', 'Read', 'None')
            $stream.Close()
            return $false
        } catch {
            return $true
        }
    }

    # Załaduj odpowiednie zestawy
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    while ($true) {
        # Zbieranie plików starszych niż 20 dni
        $filesToCompress = Get-ChildItem -Path $SourcePath -File | Where-Object {
            $_.LastWriteTime -lt (Get-Date).AddDays(-20) -and -not (Is-FileInUse -filePath $_.FullName)
        }

        if ($filesToCompress.Count -eq 0) {
            break
        }

        # Wybieranie pierwszych 10 plików do kompresji
        $filesBatch = $filesToCompress | Select-Object -First 10
        if ($filesBatch.Count -ge 10) {
            # Tworzenie archiwum
            $timestamp = Get-Date -Format "dd-MM-yyyy_HH-mm-ss"
            $archiveName = "archive_$timestamp.zip"
            $archivePath = Join-Path -Path $OutputPath -ChildPath $archiveName

            # Tworzenie archiwum z mocniejszą kompresją
            $zip = [System.IO.Compression.ZipFile]::Open($archivePath, [System.IO.Compression.ZipArchiveMode]::Create)

            foreach ($file in $filesBatch) {
            $total += 1
                if (-not [string]::IsNullOrWhiteSpace($file.Name)) {
                    # Tworzenie wpisu w archiwum
                    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $file.Name, [System.IO.Compression.CompressionLevel]::Optimal)
                    Clear-Host
                    Write-Progress -Activity "Add to Archives" -Status " $total/$allFileCount Files" -PercentComplete ( $total / $allFileCount * 100)
                } else {
                    Write-Host "Pusty plik: $($file.FullName), pomijam."
                }
            }

            $zip.Dispose()

            # Przenoszenie skompresowanych plików
            foreach ($file in $filesBatch) {
                Move-Item -Path $file.FullName -Destination $DestinationPath -Force
            }
        } else {
            exit
        }

    }
}
# SIG # Begin signature block
# MIIFjQYJKoZIhvcNAQcCoIIFfjCCBXoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAPvguK0ehxjv25XqqEIjKjCh
# V7+gggMnMIIDIzCCAgugAwIBAgIQejcWDk/lGK5MdcpcyZxgBjANBgkqhkiG9w0B
# AQUFADAbMRkwFwYDVQQDDBBMYXp5U2NyaXB0VHVydGxlMB4XDTI0MTAzMTA5MjQx
# M1oXDTM0MTAzMTA5MzQxM1owGzEZMBcGA1UEAwwQTGF6eVNjcmlwdFR1cnRsZTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJz6d43WDjnR+UHWBVK990vf
# Up1YotDErRDEsL07VFlLf/P/iljrZDOesqRFadcK87fmrFBsHQge1bqQPYie/BRn
# CtmuqgUBRK5eIlhLYQBmjncuCHL/qcASzgrT9WmivEyJD5Yt3PeISJOOWWYOU8bj
# xCWbHeeTwvGXFTFYfD9+T1p3dPsJ+d1xkVxnQe7JECjE3IPbycLZhxnJxNH2DpVH
# GAeN8KGG+KcxuJtnzpwA2O3kQIbFZsl4fGZ9uOBPqFhu4g29jtLEk3b1byBkDOcA
# dkB4i5fHrVnSs6trsnG5H/5NrVYvj7tMdCeJnwzLB4w7yxCaR4UYRdq6MVKQ4v0C
# AwEAAaNjMGEwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsG
# A1UdEQQUMBKCEExhenlTY3JpcHRUdXJ0bGUwHQYDVR0OBBYEFABN6yQfpg4TB5Mw
# 5+vLgebC9tGvMA0GCSqGSIb3DQEBBQUAA4IBAQAePqOzciA9Bi5vBjEXxdmJkWHs
# A/PZuaD7esJh5c7MVW15QUKGIy7OsdD2pXpkhSsHNUO/n7If8VRyChSfzs/owwZY
# WvJyxWHtGUDi+zY6Tk4QvePO2vlA7UTprygQAozcsN/PWZ1oQWnoMWSmHB5iQkvF
# bj1abLLD++x8RJWjFbIw6s9vNEQcO/IlgPGWBct4gtPdPEYYfNM0igBDl6ZGz2yz
# OCmehnF/Hk28DlaW7OK4TRJTgXt40wEfWrZUWO6Z839HcdQ/C+P5dJ2Ts6PZ09B3
# Gl0qm2icfLP2vZtGJkg1Uh3k1RZ+X7ETSN+XFq8VCQtOOodKxPBLp7tNYQe0MYIB
# 0DCCAcwCAQEwLzAbMRkwFwYDVQQDDBBMYXp5U2NyaXB0VHVydGxlAhB6NxYOT+UY
# rkx1ylzJnGAGMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAA
# MBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgor
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRZBIrGuiEe6n7uvP6I3GJZoXxRxjAN
# BgkqhkiG9w0BAQEFAASCAQAMGtOwqh8Tfi6V6vBrzjtaQi9CiLP/AS67TSTJXsQa
# GqP2pbO2aAuDlC465cOu7975HmjccVK6Uv7YRsn7ymrqcOvG4F8cGLt7OZDXsYOo
# /rjCZK1voMN/3dD2D1oYo6d7qcVhgG/vA0FaBgRzt2BcDOGAUnF8WOiE6iUpoTOv
# YgSQTl+Ncz7ML1am2n2TpNhM09pC+4H9CI24vN8zgKk0dVlVjcM80YKEeD5EQkYc
# VBN6zi6i2j4RbKOoHzEwh9GuaMOiSZqJhzlUFSQB5XIjsCyFdWBWMnuxE5Pb9xBJ
# zwRK4o7ABmWfvsK0docDb6fopII8vhNgbRcrKU7kpNF0
# SIG # End signature block
