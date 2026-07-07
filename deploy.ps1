$ErrorActionPreference = "Stop"

$QtBin = "A:/app/QT/6.8.3/mingw_64/bin"
$MingwBin = "A:/app/QT/Tools/mingw1310_64/bin"
$Ninja = "A:/app/QT/Tools/Ninja/ninja.exe"
$WinDeployQt = "$QtBin/windeployqt.exe"
$BuildDir = "build/Desktop_Qt_6_8_3_MinGW_64_bit-Debug"
$DeployDir = "deploy"
$ExeName = "DeepSpaceAssistant.exe"

$startTime = Get-Date
$env:PATH = "$QtBin;$MingwBin;" + $env:PATH

Write-Host "========== [1/4] Compile ==========" -ForegroundColor Cyan
Push-Location $BuildDir
& $Ninja
Pop-Location
if ($LASTEXITCODE -ne 0) { Write-Host "Compile failed!" -ForegroundColor Red; exit 1 }
Write-Host "Compile OK" -ForegroundColor Green

Write-Host "`n========== [2/4] Prepare deploy dir ==========" -ForegroundColor Cyan
if (Test-Path $DeployDir) { Remove-Item -LiteralPath $DeployDir -Recurse -Force }
New-Item -ItemType Directory -Path $DeployDir | Out-Null
Copy-Item "$BuildDir/$ExeName" "$DeployDir/"
Write-Host "Copied $ExeName" -ForegroundColor Green

Write-Host "`n========== [3/4] windeployqt ==========" -ForegroundColor Cyan
& $WinDeployQt --qmldir "$PSScriptRoot/src/frontend/qml" "$PSScriptRoot/$DeployDir/$ExeName"
if ($LASTEXITCODE -ne 0) { Write-Host "windeployqt failed!" -ForegroundColor Red; exit 1 }
Write-Host "windeployqt OK" -ForegroundColor Green

Write-Host "`n========== [4/4] Build python tools ==========" -ForegroundColor Cyan
Push-Location scripts
python -m PyInstaller --clean convert_image.spec
if ($LASTEXITCODE -ne 0) { Pop-Location; Write-Host "PyInstaller convert_image failed!" -ForegroundColor Red; exit 1 }
python -m PyInstaller --clean voice_clone.spec
Pop-Location
if ($LASTEXITCODE -ne 0) { Write-Host "PyInstaller voice_clone failed!" -ForegroundColor Red; exit 1 }
New-Item -ItemType Directory -Path "$DeployDir/python" -Force | Out-Null
Copy-Item "scripts/dist/convert_image.exe" "$DeployDir/python/" -Force
Copy-Item "scripts/dist/voice_clone.exe" "$DeployDir/python/" -Force
Write-Host "python tools OK" -ForegroundColor Green

$elapsed = ((Get-Date) - $startTime).TotalSeconds
$totalSize = (Get-ChildItem -LiteralPath $DeployDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
$totalFiles = (Get-ChildItem -LiteralPath $DeployDir -Recurse -File).Count

Write-Host "`n========== Deploy complete ==========" -ForegroundColor Cyan
Write-Host ("Time: {0:N1}s | Files: {1} | Size: {2:N2} MB" -f $elapsed, $totalFiles, ($totalSize / 1MB)) -ForegroundColor Yellow
Write-Host "Output: $DeployDir/" -ForegroundColor Yellow
