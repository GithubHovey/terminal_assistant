$ErrorActionPreference = "Stop"

$QtBin = "A:/app/QT/6.8.3/mingw_64/bin"
$MingwBin = "A:/app/QT/Tools/mingw1310_64/bin"
$Ninja = "A:/app/QT/Tools/Ninja/ninja.exe"
$WinDeployQt = "$QtBin/windeployqt.exe"
$BuildDir = "build/Desktop_Qt_6_8_3_MinGW_64_bit-Debug"
$DeployDir = "deploy"
$ExeName = "DeepSpaceAssistant.exe"
$WinRar = "C:\Program Files\WinRAR\WinRAR.exe"

$cmakeContent = Get-Content "$PSScriptRoot/CMakeLists.txt" -Raw
$Version = [regex]::Match($cmakeContent, 'VERSION\s+(\d+\.\d+\.\d+)').Groups[1].Value
$ReleaseName = "TerminalAssistantV$Version"

$startTime = Get-Date
$env:PATH = "$QtBin;$MingwBin;" + $env:PATH

Write-Host "========== [1/7] Compile ==========" -ForegroundColor Cyan
Push-Location $BuildDir
& $Ninja
Pop-Location
if ($LASTEXITCODE -ne 0) { Write-Host "Compile failed!" -ForegroundColor Red; exit 1 }
Write-Host "Compile OK" -ForegroundColor Green

Write-Host "`n========== [2/7] Prepare deploy dir ==========" -ForegroundColor Cyan
if (Test-Path $DeployDir) { Remove-Item -LiteralPath $DeployDir -Recurse -Force }
New-Item -ItemType Directory -Path $DeployDir | Out-Null
Copy-Item "$BuildDir/$ExeName" "$DeployDir/"
Write-Host "Copied $ExeName" -ForegroundColor Green

Write-Host "`n========== [3/7] windeployqt ==========" -ForegroundColor Cyan
& $WinDeployQt --qmldir "$PSScriptRoot/src/frontend/qml" "$PSScriptRoot/$DeployDir/$ExeName"
if ($LASTEXITCODE -ne 0) { Write-Host "windeployqt failed!" -ForegroundColor Red; exit 1 }
Write-Host "windeployqt OK" -ForegroundColor Green

Write-Host "`n========== [4/7] Build python tools ==========" -ForegroundColor Cyan
Push-Location scripts
python -m PyInstaller --clean convert_image.spec
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Host "PyInstaller convert_image failed!" -ForegroundColor Red; exit 1 }
python -m PyInstaller --clean voice_clone.spec
Pop-Location
if ($LASTEXITCODE -ne 0) { Write-Host "PyInstaller voice_clone failed!" -ForegroundColor Red; exit 1 }
New-Item -ItemType Directory -Path "$DeployDir/python" -Force | Out-Null
Copy-Item "scripts/dist/convert_image.exe" "$DeployDir/python/" -Force
Copy-Item "scripts/dist/voice_clone.exe" "$DeployDir/python/" -Force
Copy-Item "scripts/dist/ffmpeg.exe" "$DeployDir/python/" -Force
Write-Host "python tools OK" -ForegroundColor Green

Write-Host "`n========== [5/7] Copy resource directories ==========" -ForegroundColor Cyan

New-Item -ItemType Directory -Path "$DeployDir/materials" -Force | Out-Null
Copy-Item "$BuildDir/materials/option.json" "$DeployDir/materials/" -Force
Write-Host "Copied materials/option.json" -ForegroundColor Green

New-Item -ItemType Directory -Path "$DeployDir/bootlogo" -Force | Out-Null
Write-Host "Created empty bootlogo/" -ForegroundColor Green

New-Item -ItemType Directory -Path "$DeployDir/character" -Force | Out-Null
'{"roles":[]}' | Out-File -FilePath "$DeployDir/character/character_config.json" -Encoding utf8
Write-Host "Created empty character/character_config.json" -ForegroundColor Green

New-Item -ItemType Directory -Path "$DeployDir/music" -Force | Out-Null
'{"songs":[]}' | Out-File -FilePath "$DeployDir/music/radio_config.json" -Encoding utf8
Write-Host "Created empty music/radio_config.json" -ForegroundColor Green

'{"apikey":"","workspace_id":""}' | Out-File -FilePath "$DeployDir/config.json" -Encoding utf8
Write-Host "Created empty config.json" -ForegroundColor Green

Write-Host "Resource directories OK" -ForegroundColor Green

Write-Host "`n========== [6/7] Rename to release folder ==========" -ForegroundColor Cyan
$ReleaseDir = $ReleaseName
if (Test-Path $ReleaseDir) { Remove-Item -LiteralPath $ReleaseDir -Recurse -Force }
Rename-Item -Path $DeployDir -NewName $ReleaseDir
Write-Host "Renamed $DeployDir -> $ReleaseDir" -ForegroundColor Green

Write-Host "`n========== [7/7] Package release ==========" -ForegroundColor Cyan
$ParentDir = Split-Path -Parent $PSScriptRoot
$ReleasePath = Join-Path $ParentDir $ReleaseDir
$RarPath = "$ReleasePath.rar"
if (Test-Path $ReleasePath) { Remove-Item -LiteralPath $ReleasePath -Recurse -Force }
if (Test-Path $RarPath) { Remove-Item -LiteralPath $RarPath -Force }
Copy-Item -Path $ReleaseDir -Destination $ParentDir -Recurse
Write-Host "Copied to $ReleasePath" -ForegroundColor Green

if (Test-Path $WinRar) {
    & $WinRar a -afzip -m5 -r "$RarPath" "$ReleasePath"
    if ($LASTEXITCODE -ne 0) { Write-Host "RAR compression failed!" -ForegroundColor Red; exit 1 }
    Write-Host "Compressed to $RarPath" -ForegroundColor Green
} else {
    Write-Host "WinRAR not found at $WinRar, skipping RAR compression" -ForegroundColor Yellow
}

$elapsed = ((Get-Date) - $startTime).TotalSeconds
$deploySize = (Get-ChildItem -LiteralPath $ReleaseDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
$deployFiles = (Get-ChildItem -LiteralPath $ReleaseDir -Recurse -File).Count

Write-Host "`n========== Deploy complete ==========" -ForegroundColor Cyan
Write-Host ("Time: {0:N1}s | Files: {1} | Size: {2:N2} MB" -f $elapsed, $deployFiles, ($deploySize / 1MB)) -ForegroundColor Yellow
Write-Host "Output: $ReleaseDir/" -ForegroundColor Yellow
if (Test-Path $RarPath) {
    $rarSize = (Get-Item $RarPath).Length
    Write-Host "RAR: $RarPath ($([math]::Round($rarSize / 1MB, 2)) MB)" -ForegroundColor Yellow
}
