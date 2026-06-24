#requires -RunAsAdministrator

$ErrorActionPreference = "Continue"

#############################################################
# HELPER FUNCTIONS
#############################################################

function Test-ChocoPackageInstalled {
    param([string]$Package)

    try {
        $installed = choco list --local-only | Select-String "^$Package"
        return [bool]$installed
    }
    catch {
        return $false
    }
}

function Install-ChocoPackage {
    param([string]$Package)

    if (!(Test-ChocoPackageInstalled $Package)) {

        Write-Host "[*] Installing $Package" -ForegroundColor Cyan

        choco install $Package -y --ignore-checksums --accept-license
    }
    else {
        Write-Host "[=] $Package already installed"
    }
}

function Test-GitRepoExists {
    param([string]$RepoName)

    return Test-Path "C:\OSINT\$RepoName\.git"
}

function Test-PyPiPackageAvailable {
    param([string]$Package)

    python -m pip index versions $Package 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Test-PipPackageInstalled {
    param([string]$Package)

    python -m pip show $Package 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Test-PipxPackageInstalled {
    param([string]$Package)

    if (-not (Get-Command pipx -ErrorAction SilentlyContinue)) {
        return $false
    }

    $installed = pipx list --short 2>$null | Select-String -Pattern "^$Package\s"
    return [bool]$installed
}

function Remove-OsintGitClone {
    param([string]$RepoName)

    $repoPath = Join-Path $ToolsDir $RepoName

    if (Test-Path $repoPath) {
        Write-Host "[*] Removing git clone at $repoPath (switching to package install)" -ForegroundColor Yellow
        Remove-Item $repoPath -Recurse -Force
    }
}

function Install-OsintPipTool {
    param(
        [string]$Package,
        [ValidateSet("pip", "pipx")]
        [string]$Method
    )

    if ($Method -eq "pipx") {
        if (Test-PipxPackageInstalled $Package) {
            Write-Host "[=] $Package already installed via pipx"
            pipx upgrade $Package 2>$null | Out-Null
        }
        else {
            Write-Host "[*] Installing $Package via pipx" -ForegroundColor Cyan
            pipx install $Package
        }
    }
    else {
        if (Test-PipPackageInstalled $Package) {
            Write-Host "[=] $Package already installed via pip"
        }
        else {
            Write-Host "[*] Installing $Package via pip" -ForegroundColor Cyan
        }

        pip install --upgrade $Package
    }
}

function Install-OsintGitRepo {
    param(
        [string]$RepoUrl,
        [string]$RepoName,
        [switch]$RunSetup
    )

    $repoPath = Join-Path $ToolsDir $RepoName

    if (Test-GitRepoExists $RepoName) {
        Write-Host "[=] $RepoName already cloned at $repoPath"

        if ($RunSetup) {
            Invoke-GitRepoSetup -RepoName $RepoName -RepoPath $repoPath
        }

        return
    }

    Write-Host "[*] Cloning $RepoName from GitHub" -ForegroundColor Cyan

    try {
        git clone $RepoUrl

        if ($RunSetup -and (Test-GitRepoExists $RepoName)) {
            Invoke-GitRepoSetup -RepoName $RepoName -RepoPath $repoPath
        }
    }
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function New-ShortcutFile {
    param(
        [string]$Path,
        [string]$Target,
        [string]$Arguments = "",
        [string]$WorkingDirectory = ""
    )

    $Wsh = New-Object -ComObject WScript.Shell
    $Link = $Wsh.CreateShortcut($Path)
    $Link.TargetPath = $Target

    if ($Arguments) {
        $Link.Arguments = $Arguments
    }

    if ($WorkingDirectory) {
        $Link.WorkingDirectory = $WorkingDirectory
    }

    $Link.Save()
}

function Pin-ShortcutToTaskbar {
    param([string]$ShortcutPath)

    if (-not (Test-Path $ShortcutPath)) {
        Write-Host "[!] Cannot pin missing shortcut: $ShortcutPath" -ForegroundColor Yellow
        return
    }

    $TaskbarDir = Join-Path $env:APPDATA `
        "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"

    New-Item -ItemType Directory -Force -Path $TaskbarDir | Out-Null

    $PinPath = Join-Path $TaskbarDir (Split-Path $ShortcutPath -Leaf)
    Copy-Item -Path $ShortcutPath -Destination $PinPath -Force

    try {
        $Shell = New-Object -ComObject Shell.Application
        $Folder = $Shell.Namespace((Split-Path $PinPath))
        $Item = $Folder.ParseName((Split-Path $PinPath -Leaf))
        $Item.InvokeVerb("taskbarpin")
    }
    catch {
        # Windows 11 may block the shell verb; copied shortcut still applies on many builds.
    }

    Write-Host "[*] Pinned to taskbar: $(Split-Path $ShortcutPath -Leaf)" -ForegroundColor Cyan
}

function Install-MaltegoTool {
    $candidatePaths = @(
        "${env:ProgramFiles}\Maltego\Maltego.exe",
        "${env:ProgramFiles}\Maltego\bin\Maltego.exe",
        "${env:ProgramFiles(x86)}\Maltego\Maltego.exe"
    )

    $maltegoExe = $candidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $maltegoExe) {
        Write-Host "[*] Installing Maltego from https://www.maltego.com" -ForegroundColor Cyan

        winget install -e --id Maltego.Maltego `
            --accept-package-agreements `
            --accept-source-agreements

        $maltegoExe = $candidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    }
    else {
        Write-Host "[=] Maltego already installed"
    }

    if ($maltegoExe) {
        Write-Host "[=] Maltego executable: $maltegoExe" -ForegroundColor Green
    }
    else {
        Write-Host "[!] Maltego install finished but executable was not found" -ForegroundColor Yellow
    }

    return $maltegoExe
}

function Wait-DockerReady {
    param([int]$MaxAttempts = 60)

    for ($i = 0; $i -lt $MaxAttempts; $i++) {
        docker info 2>$null | Out-Null

        if ($LASTEXITCODE -eq 0) {
            return $true
        }

        if ($i -eq 0 -or (($i + 1) % 6) -eq 0) {
            Write-Host "[*] Docker not ready yet; waiting... ($($i + 1)/$MaxAttempts)" -ForegroundColor DarkCyan
        }

        Start-Sleep -Seconds 5
    }

    return $false
}

function Install-DockerDesktop {
    $dockerDesktopExe = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
    $dockerBinDir = "${env:ProgramFiles}\Docker\Docker\resources\bin"

    if (-not (Test-Path $dockerDesktopExe)) {
        Write-Host "[*] Installing Docker Desktop (required for flowsint)" -ForegroundColor Cyan
        Install-ChocoPackage "docker-desktop"
        refreshenv
    }
    else {
        Write-Host "[=] Docker Desktop already installed"
    }

    if (Test-Path $dockerBinDir) {
        if ($env:Path -notlike "*$dockerBinDir*") {
            $env:Path = "$dockerBinDir;$env:Path"
        }
    }

    return (Test-Path $dockerDesktopExe)
}

function Start-DockerDesktop {
    $dockerDesktopExe = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"

    if (-not (Test-Path $dockerDesktopExe)) {
        Write-Host "[!] Docker Desktop executable not found at $dockerDesktopExe" -ForegroundColor Yellow
        return $false
    }

    $running = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue

    if ($running) {
        Write-Host "[=] Docker Desktop is already running"
        return $true
    }

    Write-Host "[*] Starting Docker Desktop" -ForegroundColor Cyan
    Start-Process $dockerDesktopExe

    return $true
}

function Ensure-DockerDesktopForFlowsint {
    if (-not (Install-DockerDesktop)) {
        Write-Host "[!] Docker Desktop installation failed or is incomplete" -ForegroundColor Yellow
        Write-Host "[!] A reboot may be required after first-time Docker Desktop install" -ForegroundColor Yellow
        return $false
    }

    if (-not (Start-DockerDesktop)) {
        return $false
    }

    return $true
}

function Install-FlowsintRepo {
    param([string]$RepoPath)

    Write-Host "[*] flowsint: copying .env files (README Windows setup)" -ForegroundColor Cyan

    $envExample = Join-Path $RepoPath ".env.example"
    $envTargets = @(
        ".env",
        "flowsint-api\.env",
        "flowsint-core\.env",
        "flowsint-app\.env"
    )

    foreach ($relPath in $envTargets) {
        $dest = Join-Path $RepoPath $relPath
        $destDir = Split-Path $dest -Parent

        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        }

        Copy-Item $envExample $dest -Force
        Write-Host "[=] flowsint: copied .env -> $relPath"
    }

    if (-not (Ensure-DockerDesktopForFlowsint)) {
        Write-Host "[!] flowsint env prepared but containers not started (Docker unavailable)" -ForegroundColor Yellow
        return
    }

    Write-Host "[*] flowsint: waiting for Docker Desktop engine to become ready" -ForegroundColor Cyan

    if (-not (Wait-DockerReady)) {
        Write-Host "[!] Docker engine not ready; try again after Docker Desktop finishes starting" -ForegroundColor Yellow
        Write-Host "[!] If this is a fresh Docker install, reboot then run:" -ForegroundColor Yellow
        Write-Host "    flowsint" -ForegroundColor Yellow
        return
    }

    Push-Location $RepoPath

    Write-Host "[*] flowsint: docker compose -f docker-compose.prod.yml up -d" -ForegroundColor Cyan
    docker compose -f docker-compose.prod.yml up -d

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] flowsint docker compose failed (exit $LASTEXITCODE)" -ForegroundColor Red
        Pop-Location
        return
    }

    Pop-Location

    Write-Host "[=] flowsint stack started" -ForegroundColor Green
    Write-Host "[*] flowsint: create your account at http://localhost:5173/register" -ForegroundColor Green
}

function Invoke-GitRepoSetup {
    param(
        [string]$RepoName,
        [string]$RepoPath
    )

    switch ($RepoName) {
        "spiderfoot" {
            $req = Join-Path $RepoPath "requirements.txt"

            if (Test-Path $req) {
                Write-Host "[*] spiderfoot: pip install -r requirements.txt (per README)" -ForegroundColor Cyan
                pip install -r $req
            }
        }
        "theHarvester" {
            Write-Host "[*] theHarvester: uv sync (per README)" -ForegroundColor Cyan

            if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
                pip install uv
            }

            Push-Location $RepoPath
            uv sync
            Pop-Location
        }
        "blackbird" {
            $req = Join-Path $RepoPath "requirements.txt"

            if (Test-Path $req) {
                Write-Host "[*] blackbird: pip install -r requirements.txt (per README)" -ForegroundColor Cyan
                pip install -r $req
            }
        }
        "flowsint" {
            Install-FlowsintRepo -RepoPath $RepoPath
        }
        default {
            $req = Join-Path $RepoPath "requirements.txt"

            if (Test-Path $req) {
                Write-Host "[*] $RepoName`: pip install -r requirements.txt" -ForegroundColor Cyan
                pip install -r $req
            }
        }
    }
}

function Install-PhoneInfogaBinary {
    $installDir = "C:\OSINT\bin"

    New-Item -ItemType Directory -Force -Path $installDir | Out-Null

    $targetExe = Join-Path $installDir "phoneinfoga.exe"

    if (Test-GitRepoExists "PhoneInfoga") {
        Write-Host "[*] PhoneInfoga: removing git clone (README uses release binary)" -ForegroundColor Yellow
        Remove-OsintGitClone -RepoName "PhoneInfoga"
    }

    if (Test-Path $targetExe) {
        Write-Host "[=] PhoneInfoga binary already installed"
        return $targetExe
    }

    Write-Host "[*] PhoneInfoga: downloading Windows binary from GitHub releases" -ForegroundColor Cyan

    try {
        $release = Invoke-RestMethod `
            -Uri "https://api.github.com/repos/sundowndev/phoneinfoga/releases/latest"

        $asset = $release.assets |
            Where-Object { $_.name -match "Windows.*x86_64.*\.zip$" } |
            Select-Object -First 1

        if (-not $asset) {
            throw "Windows x86_64 release asset not found"
        }

        $zipPath = Join-Path $env:TEMP $asset.name

        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
        Remove-Item $zipPath -Force

        if (-not (Test-Path $targetExe)) {
            $found = Get-ChildItem $installDir -Filter "phoneinfoga.exe" -Recurse |
                Select-Object -First 1

            if ($found -and $found.FullName -ne $targetExe) {
                Move-Item $found.FullName $targetExe -Force
            }
        }
    }
    catch {
        Write-Host "[!] PhoneInfoga binary install failed: $($_.Exception.Message)" -ForegroundColor Red
    }

    return $targetExe
}

function Install-ChromeBrowser {
    param(
        [string]$ChromeExePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    )

    if (Test-Path $ChromeExePath) {
        Write-Host "[=] Google Chrome already installed"
        return $true
    }

    Write-Host "[*] Installing Google Chrome (required before bookmarks/extensions)" -ForegroundColor Cyan
    Install-ChocoPackage "googlechrome"
    refreshenv

    for ($i = 0; $i -lt 24; $i++) {
        if (Test-Path $ChromeExePath) {
            Write-Host "[=] Google Chrome ready: $ChromeExePath" -ForegroundColor Green
            return $true
        }

        Start-Sleep -Seconds 5
    }

    Write-Host "[!] Google Chrome install did not finish; chrome.exe not found" -ForegroundColor Red
    return $false
}

function Test-ChromeReady {
    param(
        [string]$ChromeExePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    )

    if (Test-Path $ChromeExePath) {
        return $true
    }

    Write-Host "[!] Chrome is not installed; skipping Chrome configuration" -ForegroundColor Yellow
    return $false
}

function Install-GoProjectDiscoveryTool {
    param(
        [string]$Name,
        [string]$Module,
        [string]$RepoName
    )

    if (Test-GitRepoExists $RepoName) {
        Write-Host "[*] $Name`: removing git clone (README uses go install)" -ForegroundColor Yellow
        Remove-OsintGitClone -RepoName $RepoName
    }

    if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
        Write-Host "[!] Go not available; skipping $Name" -ForegroundColor Yellow
        return
    }

    $goBin = Join-Path $env:USERPROFILE "go\bin"
    $env:Path += ";$goBin"

    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Write-Host "[=] $Name already installed via go install; upgrading" -ForegroundColor Cyan
    }
    else {
        Write-Host "[*] $Name`: go install $Module (per README)" -ForegroundColor Cyan
    }

    go install -v $Module
}

#############################################################
# VARIABLES
#############################################################

$ToolsDir = "C:\OSINT"

$Desktop = [Environment]::GetFolderPath("Desktop")

$ChromeProfile = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"

$BookmarksFile = "$ChromeProfile\Bookmarks"

$chromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"

$WallpaperUrl = "https://www.zenarmor.com/docs/assets/images/figure-1-osint-53dc3ad36af8787e0f883721eca39b96.png"

$WallpaperPath = "C:\OSINT\osint-wallpaper.png"

New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null

#############################################################
# CHOCOLATEY
#############################################################

if (!(Get-Command choco -ErrorAction SilentlyContinue)) {

    Set-ExecutionPolicy Bypass -Scope Process -Force

    [System.Net.ServicePointManager]::SecurityProtocol = `
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

    Invoke-Expression (
        (New-Object System.Net.WebClient).DownloadString(
            'https://community.chocolatey.org/install.ps1'
        )
    )
}

Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

refreshenv

#############################################################
# INSTALL CHROME (before bookmarks, profile, extensions)
#############################################################

$ChromeInstalled = Install-ChromeBrowser -ChromeExePath $chromeExe

if (-not $ChromeInstalled) {
    Write-Host "[!] Chrome install failed; bookmark and extension steps will be skipped" -ForegroundColor Yellow
}

#############################################################
# INSTALL SOFTWARE
#############################################################

$packages = @(
    "git",
    "python312",
    "vscode",
    "notepadplusplus",
    "emeditor-free",
    "obsidian",
    "7zip",
    "exiftool",
    "curl",
    "jq",
    "sysinternals",
    "tor-browser",
    "protonvpn",
    "wireshark",
    "ffmpeg",
    "vlc",
    "obs-studio",
    "sqlitebrowser",
    "openvpn",
    "nmap",
    "gh",
    "golang",
    "nodejs",
    "yarn",
    "docker-desktop"
)

foreach ($pkg in $packages) {
    Install-ChocoPackage $pkg
}

#############################################################
# REFRESH PATHS
#############################################################

$env:Path += ";C:\Python312"
$env:Path += ";C:\Python312\Scripts"
$env:Path += ";C:\Program Files\Git\cmd"

refreshenv

#############################################################
# VERIFY CORE TOOLS
#############################################################

python --version
pip --version
git --version

#############################################################
# INSTALL MALTEGO
#############################################################

$MaltegoExe = Install-MaltegoTool

#############################################################
# PYTHON / PIPX SETUP
#############################################################

python -m pip install --upgrade pip setuptools wheel pipx

python -m pipx ensurepath --global 2>$null | Out-Null

$PipxBin = Join-Path $env:USERPROFILE ".local\bin"
$env:Path += ";$PipxBin"

#############################################################
# OSINT TOOLS (pip/pipx preferred over git clone)
#############################################################
# PyPI availability verified Jun 2026. Go-only tools stay on git clone.

Set-Location $ToolsDir

$OsintToolSources = @(
    @{
        RepoName = "sherlock"
        RepoUrl  = "https://github.com/sherlock-project/sherlock.git"
        Package  = "sherlock-project"
        Method   = "pipx"
    },
    @{
        RepoName = "holehe"
        RepoUrl  = "https://github.com/megadose/holehe.git"
        Package  = "holehe"
        Method   = "pip"
    },
    @{
        RepoName = "GHunt"
        RepoUrl  = "https://github.com/mxrch/GHunt.git"
        Package  = "ghunt"
        Method   = "pipx"
    },
    @{
        RepoName = "GitFive"
        RepoUrl  = "https://github.com/mxrch/GitFive.git"
        Package  = "gitfive"
        Method   = "pipx"
    },
    @{
        RepoName = "maigret"
        RepoUrl  = "https://github.com/soxoj/maigret.git"
        Package  = "maigret"
        Method   = "pipx"
    },
    @{
        RepoName = "h8mail"
        RepoUrl  = "https://github.com/khast3x/h8mail.git"
        Package  = "h8mail"
        Method   = "pip"
    },
    @{
        RepoName = "telegram-phone-number-checker"
        RepoUrl  = "https://github.com/bellingcat/telegram-phone-number-checker.git"
        Package  = "telegram-phone-number-checker"
        Method   = "pipx"
    },
    @{
        RepoName = "blackbird"
        RepoUrl  = "https://github.com/p1ngul1n0/blackbird.git"
        Package  = $null
        Method   = "git"
    },
    @{
        RepoName = "flowsint"
        RepoUrl  = "https://github.com/reconurge/flowsint.git"
        Package  = $null
        Method   = "git"
    },
    @{
        RepoName = "spiderfoot"
        RepoUrl  = "https://github.com/smicallef/spiderfoot.git"
        Package  = $null
        Method   = "git"
    },
    @{
        RepoName = "theHarvester"
        RepoUrl  = "https://github.com/laramies/theHarvester.git"
        Package  = $null
        Method   = "git"
    }
)

$PipOnlyExtras = @(
    "instagram-location-search",
    "instaloader"
)

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Installing OSINT tools"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($tool in $OsintToolSources) {

    if ($tool.Method -in @("pip", "pipx")) {

        if (-not (Test-PyPiPackageAvailable $tool.Package)) {
            Write-Host "[!] $($tool.RepoName): $($tool.Package) not on PyPI; using git clone" -ForegroundColor Yellow
            Install-OsintGitRepo -RepoUrl $tool.RepoUrl -RepoName $tool.RepoName
            continue
        }

        if (Test-GitRepoExists $tool.RepoName) {
            Write-Host "[*] $($tool.RepoName): migrating local git clone -> $($tool.Method) package '$($tool.Package)'" -ForegroundColor Yellow
            Remove-OsintGitClone -RepoName $tool.RepoName
        }
        else {
            Write-Host "[*] $($tool.RepoName): installing via $($tool.Method) ($($tool.Package))" -ForegroundColor Cyan
        }

        Install-OsintPipTool -Package $tool.Package -Method $tool.Method
    }
    else {
        Write-Host "[*] $($tool.RepoName): git clone + README setup" -ForegroundColor Cyan
        Install-OsintGitRepo -RepoUrl $tool.RepoUrl -RepoName $tool.RepoName -RunSetup
    }
}

foreach ($pkg in $PipOnlyExtras) {
    Write-Host "[*] Installing extra pip package: $pkg" -ForegroundColor Cyan
    pip install --upgrade $pkg
}

Write-Host ""
Write-Host "[*] Installing tools with non-git README install paths" -ForegroundColor Cyan

Install-PhoneInfogaBinary

Install-GoProjectDiscoveryTool `
    -Name "subfinder" `
    -Module "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest" `
    -RepoName "subfinder"

Install-GoProjectDiscoveryTool `
    -Name "httpx" `
    -Module "github.com/projectdiscovery/httpx/cmd/httpx@latest" `
    -RepoName "httpx"

$ReposWithCustomSetup = @(
    "spiderfoot",
    "theHarvester",
    "flowsint",
    "blackbird"
)

#############################################################
# INSTALL REQUIREMENTS
#############################################################

Get-ChildItem $ToolsDir -Directory | ForEach-Object {

    if ($ReposWithCustomSetup -contains $_.Name) {
        return
    }

    $req = Join-Path $_.FullName "requirements.txt"

    if (Test-Path $req) {

        Write-Host "[*] Installing requirements for $($_.Name)"

        try {
            pip install -r $req
        }
        catch {
            Write-Host "[!] Failed requirements install for $($_.Name)"
        }
    }
}

#############################################################
# GLOBAL LAUNCHERS
#############################################################

$AliasDir = "C:\OSINT\bin"

New-Item -ItemType Directory -Force -Path $AliasDir | Out-Null

function New-Launcher {

    param(
        [string]$Name,
        [string]$Command
    )

    $bat = "@echo off`n$Command %*"

    Set-Content "$AliasDir\$Name.bat" $bat
}

New-Launcher "sherlock" "sherlock"
New-Launcher "ghunt" "ghunt"
New-Launcher "gitfive" "gitfive"
New-Launcher "maigret" "maigret"
New-Launcher "holehe" "holehe"
New-Launcher "h8mail" "h8mail"
New-Launcher "telegram-phone-number-checker" "telegram-phone-number-checker"
New-Launcher "spiderfoot" "python C:\OSINT\spiderfoot\sf.py -l 127.0.0.1:5001"
New-Launcher "theharvester" "pushd C:\OSINT\theHarvester && uv run theHarvester"
New-Launcher "phoneinfoga" "phoneinfoga"
New-Launcher "blackbird" "pushd C:\OSINT\blackbird && python blackbird.py"
New-Launcher "instaloader" "instaloader"
New-Launcher "start-docker" "start \"\" \"C:\Program Files\Docker\Docker\Docker Desktop.exe\"`ntimeout /t 10 /nobreak >nul"
New-Launcher "flowsint" "start-docker && pushd C:\OSINT\flowsint && docker compose -f docker-compose.prod.yml up -d && start http://localhost:5173"
New-Launcher "flowsint-open" "start http://localhost:5173"

$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

$MachinePathAdditions = @(
    $AliasDir,
    $PipxBin,
    "C:\Python312\Scripts",
    (Join-Path $env:USERPROFILE "go\bin"),
    "${env:ProgramFiles}\Docker\Docker\resources\bin"
)

foreach ($pathEntry in $MachinePathAdditions) {

    if ($envPath -notlike "*$pathEntry*") {
        $envPath = "$envPath;$pathEntry"
    }
}

[Environment]::SetEnvironmentVariable(
    "Path",
    $envPath,
    "Machine"
)

#############################################################
# DESKTOP SHORTCUTS
#############################################################

$WshShell = New-Object -ComObject WScript.Shell

function New-Shortcut {

    param(
        [string]$Name,
        [string]$Target,
        [string]$Arguments = ""
    )

    $Shortcut = $WshShell.CreateShortcut("$Desktop\$Name.lnk")

    $Shortcut.TargetPath = $Target

    $Shortcut.Arguments = $Arguments

    $Shortcut.Save()
}

New-Shortcut "Sherlock" "cmd.exe" "/k sherlock"
New-Shortcut "SpiderFoot" "cmd.exe" "/k spiderfoot"
New-Shortcut "GHunt" "cmd.exe" "/k ghunt"
New-Shortcut "Flowsint" "cmd.exe" "/k flowsint"

if ($MaltegoExe) {
    New-Shortcut "Maltego" $MaltegoExe
}

#############################################################
# TASKBAR PINS
#############################################################

$TaskbarShortcutDir = "C:\OSINT\Shortcuts\Taskbar"

New-Item -ItemType Directory -Force -Path $TaskbarShortcutDir | Out-Null

$TaskbarPins = @(
    @{
        Name = "Command Prompt"
        Target = "$env:SystemRoot\System32\cmd.exe"
    },
    @{
        Name = "Windows PowerShell"
        Target = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    },
    @{
        Name = "Google Chrome"
        Target = $chromeExe
    },
    @{
        Name = "Visual Studio Code"
        Target = "${env:ProgramFiles}\Microsoft VS Code\Code.exe"
    },
    @{
        Name = "Obsidian"
        Target = "$env:LOCALAPPDATA\Programs\Obsidian\Obsidian.exe"
    },
    @{
        Name = "Wireshark"
        Target = "${env:ProgramFiles}\Wireshark\Wireshark.exe"
    },
    @{
        Name = "Sherlock"
        Target = "cmd.exe"
        Arguments = "/k sherlock"
    },
    @{
        Name = "GHunt"
        Target = "cmd.exe"
        Arguments = "/k ghunt"
    },
    @{
        Name = "SpiderFoot"
        Target = "cmd.exe"
        Arguments = "/k spiderfoot"
    },
    @{
        Name = "Maigret"
        Target = "cmd.exe"
        Arguments = "/k maigret"
    },
    @{
        Name = "Flowsint"
        Target = "cmd.exe"
        Arguments = "/k flowsint"
    }
)

if ($MaltegoExe) {
    $TaskbarPins += @{
        Name = "Maltego"
        Target = $MaltegoExe
    }
}

Write-Host ""
Write-Host "[*] Pinning shortcuts to taskbar" -ForegroundColor Cyan

foreach ($pin in $TaskbarPins) {

    if ($pin.Target -notlike "cmd.exe" -and -not (Test-Path $pin.Target)) {
        Write-Host "[=] Skipping taskbar pin (not installed): $($pin.Name)"
        continue
    }

    $ShortcutPath = Join-Path $TaskbarShortcutDir "$($pin.Name).lnk"

    New-ShortcutFile `
        -Path $ShortcutPath `
        -Target $pin.Target `
        -Arguments $pin.Arguments `
        -WorkingDirectory $ToolsDir

    Pin-ShortcutToTaskbar -ShortcutPath $ShortcutPath
}

if (Test-ChromeReady -ChromeExePath $chromeExe) {

#############################################################
# INITIALIZE CHROME PROFILE
#############################################################

if (!(Test-Path $ChromeProfile)) {

    Write-Host "[*] Initializing Chrome profile"

    Start-Process $chromeExe

    Start-Sleep -Seconds 15

    Get-Process chrome -ErrorAction SilentlyContinue |
        Stop-Process -Force

    Start-Sleep -Seconds 3
}

#############################################################
# KILL CHROME BEFORE BOOKMARKS
#############################################################

Get-Process chrome -ErrorAction SilentlyContinue |
    Stop-Process -Force

Start-Sleep -Seconds 2

#############################################################
# OSINT BOOKMARKS
#############################################################

$BookmarkDir = "C:\OSINT\Bookmarks"

$BookmarkHtml = "$BookmarkDir\bookmarks_24_06_2026.html"

$BookmarkSource = Join-Path (Split-Path $PSCommandPath -Parent) "bookmarks_24_06_2026.html"

$BookmarkUrl = "https://raw.githubusercontent.com/TheUnsocialEngineer/Osint-Installer-Script/refs/heads/main/bookmarks_24_06_2026.html?token=GHSAT0AAAAAAD5J2MKY7ZCZZYUASL5XCDJY2R4BNYQ"

New-Item `
    -ItemType Directory `
    -Path $BookmarkDir `
    -Force | Out-Null

if (Test-Path $BookmarkSource) {

    Write-Host "[*] Deploying local OSINT bookmarks from installer package"

    Copy-Item `
        -Path $BookmarkSource `
        -Destination $BookmarkHtml `
        -Force
}
elseif (!(Test-Path $BookmarkHtml)) {

    Write-Host "[*] Downloading OSINT bookmarks"

    Invoke-WebRequest `
        -Uri $BookmarkUrl `
        -OutFile $BookmarkHtml
}
else {

    Write-Host "[=] Bookmark file already present"
}

#############################################################
# CHROME EXTENSION FORCE INSTALL POLICIES
#############################################################
# Verified Jun 2026 via Chrome update API.
# Source: https://github.com/ubikron/awesome-osint-chrome-extensions

$ChromePolicyRoot = "HKLM:\SOFTWARE\Policies\Google\Chrome"
$ExtensionPolicy = "$ChromePolicyRoot\ExtensionInstallForcelist"
$ChromeUpdateUrl = "https://clients2.google.com/service/update2/crx"

New-Item -Path $ChromePolicyRoot -Force | Out-Null

if (Test-Path $ExtensionPolicy) {
    Remove-Item -Path $ExtensionPolicy -Recurse -Force
}

New-Item -Path $ExtensionPolicy -Force | Out-Null

$Extensions = [ordered]@{
    "uBlock Origin" = "cjpalhdlnbpafiamejdnhcphjbkeiagm"
    "GHunt Companion" = "dpdcofblfbmmnikcbmmiakkclocadjab"
    "Wappalyzer" = "gppongmhjkpfnbhagpmjfkannfbllamg"
    "URLScan.io" = "loehkbkhflmmkempgkdpkkhghdiegicp"
    "Sputnik" = "manapjdamopgbpimgojkccikaabhmocd"
    "Shodan" = "jjalcfnidlmpjhdfepjhjbhnhkbgleap"
    "Netcraft" = "bmejphbfclcpmpohkggcjeibfilpamia"
    "DNSChecker" = "gegfpbhjnhegdnjdkghhnneaocdbbhjp"
    "Netlas.io" = "pncoieihjcmpooceknjajojehmhdedii"
    "Wayback Machine" = "fpnmgdkabkmnadcjpehmlllkndpkmiak"
    "Web Archives" = "hkligngkgcpcolhcnkgccglchdafcnao"
    "Forensic OSINT" = "jojaomahhndmeienhjihojidkddkahcn"
    "Go Full Page" = "fdpohaocaechififmbbbbbknoalclacl"
    "Save Webpages Offline As MHTML" = "nfbcfginnecenjncdjhaminfcienmehn"
    "PhotoOSINT" = "gonhdjmkgfkokhkflfhkbiagbmoolhcd"
    "Split Screen for Google Chrome" = "dnollkdkikklpdganoecjcmmlddbennb"
    "Street View Tracker" = "nlngoiabgfhbklfnidbhhcaakkojcocf"
    "Place ID Finder for Google Maps" = "gdnnaahojechcmemagbbbbnoiieolafp"
    "Search by Image" = "cnojnbdhbhnkbcieeekonklommdnndci"
    "EXIF Viewer Pro" = "mmbhfeiddhndihdjeganjggkmjapkffm"
    "Perceptual Image Analysis" = "gidmeabdffonnejjlkbglmppmfniakdf"
    "Trufflepiggy - Context Search" = "chffnhocnckigoapjdienmaphjnljpmo"
    "SearchJumper" = "hgepmblbgodbilmfdjkalkgofdcipkhh"
    "Dork Search Tool" = "neadoiokjghjpklekpjifhheaddbdjca"
    "WHO I AM" = "gdnhlhadhgnhaenfcphpeakdghkccfoo"
    "OSINT Username Search" = "hbpmcahfkjladffaenebdafoeohalfmp"
    "Context Menu Search" = "ocpcmghnefmdhljkoiapafejjohldoga"
    "Hunter.io" = "hgmhmanijnjhaffoampdlllchpolkdnj"
    "Email Extractor" = "jdianbbpnakhcmfkcckaboohfgnngfcc"
    "YouTube Channel ID Finder" = "bfkbgahmplemjmengbjlncclgcnckogb"
    "TTFinder" = "jjaeadbgppdbbdfhifejbheijbflleid"
    "IG Username to ID" = "kcdkceelebfeldicmpijnhbkoibieoji"
    "Steam ID Finder" = "iaeodlelphecgkpneeifmgcjgeoobjah"
    "InVID and WeVerify" = "mhccpoafgdgbhnjfhkcmgknndkeenfhe"
    "Instant Data Scraper" = "ofaokhiedipichpaobibbnahnkdoiiah"
    "HTML Inspector" = "fpaahdcndgfpbbddmgckaifkfljkfkhd"
    "Link Klipper" = "fahollcgofmpnehocdgofnhkkchiekoo"
    "Regex Search" = "dcnmfijohgljejnnocmbecmpccgficcm"
    "View Rendered Source" = "ejgngohbdedoabanmclafpkoogegdpob"
    "DumpItBlue+" = "igmgknoioooacbcpcfgjigbaajpelbfe"
    "YouTube Booster" = "dajnidicmkknmmbapmmmlemjdfolgjnf"
    "Chrome Extension Source Viewer" = "jifpbeccnghkjeaalbbjmodiffmgedin"
    "CRX Extractor" = "ajkhmmldknmfjnmeedkbkkojgobmljda"
    "Tampermonkey" = "dhdgffkkebhmkfjojejmpbldmpobfkfo"
    "CopyFish OCR" = "eenjdnjldapjajjofmldgmkjaienebbj"
    "Blockchair" = "fhhkkooikehnkaodebbfnkinedlllcfk"
}

$ExtensionIndex = 1

foreach ($Ext in $Extensions.GetEnumerator()) {

    $PolicyValue = "$($Ext.Value);$ChromeUpdateUrl"

    Write-Host "[*] Adding Chrome extension policy: $($Ext.Key) ($($Ext.Value))"

    New-ItemProperty `
        -Path $ExtensionPolicy `
        -Name $ExtensionIndex `
        -Value $PolicyValue `
        -PropertyType String `
        -Force | Out-Null

    $ExtensionIndex++
}

#############################################################
# RESTART CHROME SO POLICIES APPLY
#############################################################

Get-Process chrome -ErrorAction SilentlyContinue |
    Stop-Process -Force

Start-Sleep -Seconds 3

Write-Host "[*] Chrome extension policies configured."
Write-Host "[*] Extensions will install automatically when Chrome launches."

#############################################################
# SET CHROME DEFAULT
#############################################################

Start-Process $chromeExe "--make-default-browser"

}

#############################################################
# REMOVE EDGE
#############################################################

Get-Process msedge -ErrorAction SilentlyContinue |
    Stop-Process -Force

Remove-Item `
"$env:PUBLIC\Desktop\Microsoft Edge.lnk" `
-Force `
-ErrorAction SilentlyContinue

#############################################################
# WINDOWS DEBLOAT
#############################################################

$apps = @(
    "Microsoft.BingNews",
    "Microsoft.Xbox*",
    "Microsoft.Teams",
    "Clipchamp.Clipchamp",
    "Microsoft.ZuneMusic",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted"
)

foreach ($app in $apps) {

    if (Get-AppxPackage *$app* -ErrorAction SilentlyContinue) {

        Write-Host "[*] Removing $app"

        Get-AppxPackage *$app* |
            Remove-AppxPackage -ErrorAction SilentlyContinue
    }
}

#############################################################
# DISABLE TELEMETRY
#############################################################

reg add `
"HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
/v AllowTelemetry `
/t REG_DWORD `
/d 0 `
/f

#############################################################
# DISABLE WINDOWS UPDATE
#############################################################

Stop-Service wuauserv -Force -ErrorAction SilentlyContinue

Set-Service wuauserv `
-StartupType Disabled `
-ErrorAction SilentlyContinue

#############################################################
# WALLPAPER
#############################################################

if (!(Test-Path $WallpaperPath)) {

    Invoke-WebRequest `
        -Uri $WallpaperUrl `
        -OutFile $WallpaperPath
}

Add-Type @"
using System.Runtime.InteropServices;

public class Wallpaper {

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(
        int uAction,
        int uParam,
        string lpvParam,
        int fuWinIni
    );
}
"@

[Wallpaper]::SystemParametersInfo(
    20,
    0,
    $WallpaperPath,
    3
)

#############################################################
# COMPLETE
#############################################################

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host " OSINT VM setup complete"
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Reboot recommended."
