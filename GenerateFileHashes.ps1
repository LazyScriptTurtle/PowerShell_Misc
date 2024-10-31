
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