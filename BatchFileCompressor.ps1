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
# MIIFkQYJKoZIhvcNAQcCoIIFgjCCBX4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAPvguK0ehxjv25XqqEIjKjCh
# V7+gggMgMIIDHDCCAgSgAwIBAgIQFmpvPuq1U7lPT7hXCfs9YTANBgkqhkiG9w0B
# AQsFADAmMSQwIgYDVQQDDBtMYXp5U2NyaXB0VHVydGxlQ29kZVNpZ25pbmcwHhcN
# MjQxMDMxMDg1MTM1WhcNMjUxMDMxMDkxMTM1WjAmMSQwIgYDVQQDDBtMYXp5U2Ny
# aXB0VHVydGxlQ29kZVNpZ25pbmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQDIRzKiPa1HTjzSaK31aLR6WV1r6/UIViovMCRs2gQka+tYOI8U9Fq1t32Z
# i1OgCEWDqwT5ieug59uOSwM45t31esHHoGFiTasOh1cgm2so04aBtbRBubYIznIV
# CeI5Ex7KH16X8bGuzbKQ/UCNd69RacCxFZ6G7tYWnoOcHF3d7rxSrxmkq+c3b6+T
# ig2egwdoWthV+G0HNRwWq+uLvpvbsmQENJ2y8y6/sI3gfRNZRmCJ2HTpDhNtVEYd
# QT3lRT+WUzSh5mtYGp+rg+dmS4XqPrCwrQ4RjfpgrLXOOGPTJn+s6zzf1gQjDTai
# /e+okBQRAbpud5Mxr2awmjDyRu0ZAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDAT
# BgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUP9YyxRYAQnt+0voXr2o7AsHG
# AWgwDQYJKoZIhvcNAQELBQADggEBAD7MGn6p+RNRpAC/cGI1REY2cxDAAueYXm10
# w1Q2aGDyGDgmLSUXacFXrvty0UxdkaGRZ7/WFA6yV/WRLwXW9YfjLNube0xP77P5
# jpy3GWYaDoLQDFISofuQUzK4IuW4pif6qtcsCNiql+5jeBpnoNC3zuIJK8yV4Hhk
# buCL2qhL7mrFnE/CyviRSxxbwpLSZqiDEVQbHZEssCaEi/cFFT9SmJwI/pgE7h1v
# dMOIbdUhA4SHjBEWL40EThSPRoy6leQ+pGnI4YJuUz2tat10G9rvW9usQFDJieFA
# sJZCWzatM+SrpNgUna45SpndvlCbVuIKQovYHsqYdVXkyPrlsyQxggHbMIIB1wIB
# ATA6MCYxJDAiBgNVBAMMG0xhenlTY3JpcHRUdXJ0bGVDb2RlU2lnbmluZwIQFmpv
# Puq1U7lPT7hXCfs9YTAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAA
# oQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4w
# DAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUWQSKxrohHup+7rz+iNxiWaF8
# UcYwDQYJKoZIhvcNAQEBBQAEggEAGQHNsGZ18K0sq2PfpDG5VCpswKyU8aPW87Uk
# WbS0nA2ulNcYHxqX1aPTxsLdAYoxGM9l2lbKzKKHEXZeULx281nuldJtwIaDM11O
# m6ng5/n/7e7wMrXJZwb2z8c1aBjRGeDOatSYhvOS1jHUcjkuQUDq3iAg8ib+N47f
# YRT5Ug3LYQmP6q4Okxo22QsyBtY/s1quc0MUDEvnYUTlQ2ZT34UX52wL55g5nio3
# /xQmqaRe2P25WyRyGPdpiGnQH0Vai6TUryZsjbKR8jZsKyxtX9mBx5DGoHRy557k
# z3/Xr8FKxzmq4abMaDeohs7cA23pnrqiECCTWVMY0Yr+jE9W7w==
# SIG # End signature block
