Param([string]$File, [switch]$Remove, [string]$DIR)

$Files = if ($File -eq "") { Get-ChildItem -Path $DIR -File } else { @($File) }

$Files | ForEach-Object {
    $filename = [System.IO.Path]::GetFileNameWithoutExtension($_) 
    $ext = [System.IO.Path]::GetExtension($_) 
    $ls = @(Get-ChildItem -Path $DIR -Filter ($filename + "*" + $ext))
    if ($ls.Length -gt 1) { 
        $sort = $ls | Sort-Object -Property LastWriteTime -Descending
        $uniq = $null
        $sort | Select-Object -First 1 `
            | ForEach-Object { 
                Write-Output ($_.Name + '(' + $_.LastWriteTime + ')' `
                    + $(if ($Remove) { ' => ' + ($filename + $ext) } else { "" }))
                $uniq = $_
            }
        $sort | Select-Object -Skip 1 `
            | ForEach-Object { 
                Write-Output ("`t" + $(if ($Remove) {"Remove: "} else {""}) `
                     + $_.Name + '(' + $_.LastWriteTime + ')') 
                if ($Remove) { Remove-Item $_.Fullname  }
            }
        if ($Remove) { Rename-Item $uniq.Fullname -NewName ($filename + $ext) }
    }
}