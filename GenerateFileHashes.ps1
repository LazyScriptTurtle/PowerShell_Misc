
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
# MIIFjQYJKoZIhvcNAQcCoIIFfjCCBXoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUhgBVtYcsAjlGOQj392cQmuGF
# GnegggMnMIIDIzCCAgugAwIBAgIQejcWDk/lGK5MdcpcyZxgBjANBgkqhkiG9w0B
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
# BgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSG8u5q8Lsrpck2I7DjqFbhf9ecYTAN
# BgkqhkiG9w0BAQEFAASCAQAuPbsje26Ika0io5Dm7RYJ1FQnE6/hCa4/9891+qAQ
# uGUzQfEtq/Ppa8KaIvkbNrpRyqI7NnAThz+Ob26qcDp5hhbnuKH7G9tWFtKVPS6q
# UhivrlnOakIPS063mOFXt38FgErpaAgUrcdb3iZnWcAeu/fhizuT0+y3d4Zbh3sX
# JlEYdBEXAM/A0YGcoOmGBB+wOO8Utfnlr4Bp5ObMoUbq5Rq2c76y4GyUxyHA/B10
# 1EO+1fiatClPMYX2UeVeHroa8c89ia+GsLmLZrCSU7sfcPp3yiR8XIRG7Cwa0nj+
# 7Zlvp63afojbvcN1hTCNI8tASx/KPxW0VIfkL6SHAD3Y
# SIG # End signature block
