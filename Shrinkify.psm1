function global:Shrinkify {
    Param (
        [PARAMETER(Mandatory = $False)][ValidateLength(1, 50)][string[]]$include,
        [PARAMETER(Mandatory = $False)][ValidateLength(1, 15)][string]$resize,
        [PARAMETER(Mandatory = $False)][ValidateLength(3, 20)][string]$minsize,
        [switch]$recurse
    )

    $host.PrivateData.ProgressBackgroundColor = $host.UI.RawUI.BackgroundColor
    $host.privatedata.ProgressForegroundColor = "green";

    $startTime = Get-Date

    $outputFolderName = "Compressed"

    $p = Get-Location
    $path = "${p}\*"
    $includable = @("jpg", "png", "tif", "gif")
    $toInclude = @()

    if ($include) {
        $include `
        | ForEach-Object { `
                if ($_.Split(".")[1] -in $includable) `
            { $toInclude += $_ } }
    }
    else {
        $toInclude = @("*.jpg", "*.png", "*.tif", "*.gif")
    }
    
    if ($recurse) {
        $files = Get-ChildItem `
            -Recurse `
            -Include $toInclude `
        | Where-Object { ( $_.Directory.Name -notlike "*${outputFolderName}*")`
                -and ($_.Length -gt $minsize) } 
    }
    else {
        $files = Get-ChildItem `
            -Path $path `
            -Include $toInclude `
        | Where-Object { $_.Length -gt $minsize }
    }

    if (-not $resize) {
        $resize = "100%"
    }
    
    if (-not (Test-Path -Path "${p}\${outputFolderName}")) {
        mkdir Compressed | Out-Null
        Write-Host "Could not find directory '${outputFolderName}'"
        Write-Host "Created directory '${outputFolderName}'"
    }

    $filesLength = $files.Length

    $compressedFilesSize = 0 
    $uncompressedFilesSize = 0
    
    for ($a = 0; $a -le $filesLength - 1; $a++) {
        $curItemIndex = $a + 1
        $itemProgress = "${curItemIndex}/${filesLength}"
        $progress = [math]::floor(($a / $filesLength) * 100)
        # $parentPath = $files[$a].Directory.FullName;
        $fileName = $files[$a].Name;
        $fullFileName = $files[$a].FullName
        $newFilePath = "$p\Compressed$($fullFileName.Split([string[]]$p, [StringSplitOptions]::None)[1])"  
        $newDirectoryPath = $newFilePath.Replace($fileName, "")

        if (-not (Test-Path -Path $newDirectoryPath)) {
            mkdir $newDirectoryPath | Out-Null 
            Write-Host "Created directory '${newDirectoryPath}'"
        }

        $secondsElapsed = (Get-Date) - $startTime

        $progressParams = @{
            Activity         = "No successful compression yet" 
            Status           = "[$($secondsElapsed.ToString('hh\:mm\:ss'))] ${progress}% File ${itemProgress} ...  ($("{0:F2}MB" -f (($uncompressedFilesSize - $compressedFilesSize) / 1MB)) cleared)" 
            CurrentOperation = "Compressing file [${fileName}] ..." 
            PercentComplete  = $progress
        }

        if ($secondsRemaining) {
            $progressParams.SecondsRemaining = $secondsRemaining
        }

        if ($lastFilePath) {
            $progressParams.Activity = "Successfully compressed [${lastFilePath} (${oldByteSize})] to [${newFilePath} (${newByteSize})]" 
        }
        
        Write-Progress @progressParams
        magick `
            $fullFileName `
            -sampling-factor 4:2:0 `
            -strip `
            -quality 85 `
            -interlace Plane `
            -gaussian-blur 0.05 `
            -colorspace RGB `
            $newFilePath 

        magick mogrify -resize $resize $newFilePath
        
        $fileSize = ($files[$a].length)
        $newFileSize = (Get-ChildItem $newFilePath).length 

        $uncompressedFilesSize += $fileSize
        $compressedFilesSize += $newFileSize

        $oldByteSize = ("{0:F2}MB" -f ($fileSize / 1MB))
        $newByteSize = ("{0:F2}MB" -f ($newFileSize / 1MB))
        $lastFilePath = $fullFileName
        $secondsRemaining = (($secondsElapsed.TotalSeconds / ($a + 1)) * ($filesLength - ($a + 1)))
    }
    Write-Host  "`nTotal files size before: $("{0:F2}MB" -f ($uncompressedFilesSize / 1MB))"
    Write-Host  "Total files size now: $("{0:F2}MB" -f ($compressedFilesSize / 1MB))"
    Write-Host  "`nCleared $("{0:F2}MB" -f (($uncompressedFilesSize - $compressedFilesSize) / 1MB)) of diskspace"
}

Export-ModuleMember -Function Shrinkify
