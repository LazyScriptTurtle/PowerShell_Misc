
function hash_calculate {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourcePath
    )

    $Files = Get-ChildItem -Path $SourcePath -File -Recurse
    $FilesCount = $Files.Count
    $total = 0
    $hashes = @()
    $startTime = Get-Date

    foreach ($file in $Files) {
        try {
            # Calculate the file hash
            $hash = Get-FileHash -Path $file.FullName -Algorithm MD5 -ErrorAction Stop
            $hashes += [PSCustomObject] @{
                Name        = $file.Name
                Create      = $file.CreationTime
                Last_Write  = $file.LastWriteTime
                Hash        = $hash.Hash
            }

            $total += 1
            $elapsedTime = (Get-Date) - $startTime
            $averageTime = $elapsedTime.TotalSeconds / $total
            $remainingFiles = $FilesCount - $total
            $estimatedTimeRemaining = $remainingFiles * $averageTime / 60

            Write-Progress -Activity "Hash Files" -Status "$total/$FilesCount hashes" -PercentComplete (($total / $FilesCount) * 100) `
                -CurrentOperation ("Estimated time remaining: {0:N0} minutes" -f $estimatedTimeRemaining)

        } catch [System.IO.IOException] {
            Write-Host "Ignore - File is open: $file"
        } catch {
            Write-Host "Error processing file '$($file.FullName)': $($_.Exception.Message)"
        }
    }

    return $hashes
}



function Save-hashes {
param(
[Parameter(Mandatory=$true)]
[object]$hashes,

[Parameter(Mandatory=$true)]
[object]$DestintationPath
)
$hashes | ConvertTo-Json | Out-File -FilePath $DestintationPath -Encoding utf8
}

$sourcePath = Read-Host "Source Path: "
$destinationPath = Read-Host "Destination Path: "

$hashes = hash_calculate -SourcePath $sourcePath
Save-hashes -hashes $hashes -DestintationPath $destinationPath
# SIG # Begin signature block
# MIIFkQYJKoZIhvcNAQcCoIIFgjCCBX4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUhgBVtYcsAjlGOQj392cQmuGF
# GnegggMgMIIDHDCCAgSgAwIBAgIQFmpvPuq1U7lPT7hXCfs9YTANBgkqhkiG9w0B
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
# DAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUhvLuavC7K6XJNiOw46hW4X/X
# nGEwDQYJKoZIhvcNAQEBBQAEggEAuaXh7gazL7RlSFhZ21Z8suGnXmA8WihQxMTY
# jpVF//tSOYghyQWgrZxm5Px8Wh2pRfQtVqC+c9jIFXcq5MqeIFPDud/aPDy5kAY/
# wtp8gAnArRSU6AJMdgWSAqmXjSRRjVJKAPJYqvG4aGtrdp38Z8fvfoZ1n0KV0Eck
# QNQDvsQ/FnGxaQpstBIqHHm5TiEbIQuqo4ijRWifqbFJ8G3U0kJDIttkvdOWEsnP
# i7tNpuNrGQjWupyk34OKY+lY1mn8MpIFDMNe65/VIZSKCRailrVcVFNve+lyY2O/
# H00YDQQtsoSG7cPrjOyk1/QDucqysHxudccN3YSU25Th2WWiVA==
# SIG # End signature block
