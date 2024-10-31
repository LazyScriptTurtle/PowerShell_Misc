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