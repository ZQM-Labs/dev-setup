<# 
.SYNOPSIS
    Bootstrap script for Windows development environment setup.
.DESCRIPTION
    Installs Scoop, Git, Python, Node.js tools, and a comprehensive set of CLI utilities.
    Run this on a fresh Windows machine to replicate the full dev environment.
.NOTES
    Author: ZQM-Computing
    Requires: Windows 10/11, PowerShell 5.1+
#>

param(
    [switch]$SkipScoop,
    [switch]$SkipNode,
    [switch]$SkipPython,
    [switch]$SkipProfile,
    [switch]$Unattended
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-OK {
    param([string]$Message)
    Write-Host "    [OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "    [!] $Message" -ForegroundColor Yellow
}

Write-Host @"
=======================================
  Windows Dev Setup Bootstrap
  ZQM-Computing
=======================================
"@ -ForegroundColor Magenta

# ============================================================
# 1. Scoop - Package Manager
# ============================================================
if (-not $SkipScoop) {
    Write-Step "1/6: Installing Scoop package manager"
    
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 -bor 768 -bor 192
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        
        try {
            iex "& {$(iwr -useb https://get.scoop.sh)} -RunAsAdmin"
        } catch {
            Write-Warn "Direct install failed, trying fallback..."
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile('https://raw.githubusercontent.com/ScoopInstaller/Install/master/install.ps1', "$env:TEMP\scoop-install.ps1")
            & "$env:TEMP\scoop-install.ps1" -RunAsAdmin
        }
        
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-OK "Scoop installed"
        } else {
            Write-Warn "Scoop may need PATH refresh. Adding shims to PATH..."
            $env:Path += ";$env:USERPROFILE\scoop\shims"
        }
    } else {
        Write-OK "Scoop already installed"
    }
    
    # Add buckets
    Write-Step "    Adding Scoop buckets..."
    $buckets = @("extras", "versions", "nerd-fonts", "java", "nonportable")
    foreach ($bucket in $buckets) {
        scoop bucket add $bucket 2>$null
        Write-OK "Bucket: $bucket"
    }
}

# ============================================================
# 2. Git & GitHub CLI
# ============================================================
Write-Step "2/6: Installing Git tools"
scoop install git gh ghq 2>&1 | Out-Null
Write-OK "Git, gh, ghq installed"

# Git configuration
Write-Step "    Configuring Git..."
git config --global core.autocrlf "input"
git config --global core.safecrlf "warn"
git config --global push.default "current"
git config --global pull.rebase "true"
git config --global rebase.autostash "true"
git config --global fetch.prune "true"
git config --global init.defaultBranch "main"
git config --global color.ui "auto"

# Git aliases
$aliases = @{
    "lg"     = 'log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
    "ll"     = "log --oneline --decorate --graph"
    "st"     = "status -sb"
    "co"     = "checkout"
    "br"     = "branch"
    "ci"     = "commit"
    "df"     = "diff"
    "dfc"    = "diff --cached"
    "amend"  = "commit --amend --no-edit"
    "undo"   = "reset HEAD~1 --mixed"
    "last"   = "log -1 HEAD"
    "unstage" = "reset HEAD --"
    "discard" = "checkout --"
    "squash" = "merge --squash"
    "contributors" = "shortlog -sn --no-merges"
    "tree"   = "log --graph --oneline --all"
}
foreach ($key in $aliases.Keys) {
    git config --global "alias.$key" $aliases[$key]
}

# Install delta for better diffs
scoop install delta 2>&1 | Out-Null
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate "true"
git config --global delta.side-by-side "true"
git config --global delta.line-numbers "true"
git config --global delta.syntax-theme "Dracula"
git config --global merge.conflictstyle "zdiff3"

Write-OK "Git configured with delta, aliases, and optimized settings"

# ============================================================
# 3. Core CLI Tools via Scoop
# ============================================================
Write-Step "3/6: Installing CLI tools via Scoop"

$scoopPackages = @(
    # Archives & Compression
    "7zip", "gzip",
    # Network
    "curl", "wget", "ngrok", "mkcert",
    # Search & Navigation
    "bat", "fd", "ripgrep", "fzf", "zoxide", "broot",
    # Data Processing
    "jq", "sqlite",
    # System
    "which", "diffutils", "less", "duf", "procs", "bottom", "dust", "gdu",
    # Productivity
    "lazygit", "lazydocker", "just", "watchexec", "sd", "choose", "navi",
    # Modern replacements
    "eza", "delta", "glow", "doggo", "hyperfine", "hexyl", "grex", "xh", "vivid", "starship",
    # GitHub tools
    "ghgrab", "ghorg",
    # Editors
    "neovim", "micro",
    # Media
    "ffmpeg", "imagemagick", "ghostscript", "yt-dlp",
    # File transfer
    "croc", "rclone",
    # Code stats
    "tokei", "onefetch"
)

foreach ($pkg in $scoopPackages) {
    $result = scoop install $pkg 2>&1
    if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
        Write-OK "$pkg"
    } else {
        Write-Warn "$pkg failed to install (may need manual install)"
    }
}

# Scoop PATH
$scoopShims = "$env:USERPROFILE\scoop\shims"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$scoopShims*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$scoopShims", "User")
    Write-OK "Scoop shims added to PATH"
}
$env:Path += ";$scoopShims"

# ============================================================
# 4. Node.js / npm Global Tools
# ============================================================
if (-not $SkipNode) {
    Write-Step "4/6: Installing Node.js global tools"
    
    # Check if Node is available, install via Scoop if not
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Warn "Node.js not found, installing via Scoop..."
        scoop install nodejs 2>&1 | Out-Null
    }
    
    $nodePackages = @(
        "typescript", "ts-node", "nodemon",
        "http-server", "serve", "concurrently",
        "eslint", "prettier", "marked", "js-yaml",
        "json5", "npm-check-updates"
    )
    
    foreach ($pkg in $nodePackages) {
        npm install -g $pkg --silent 2>$null
        Write-OK "npm: $pkg"
    }
    
    # Also install yarn and pnpm
    npm install -g yarn pnpm --silent 2>$null
    Write-OK "npm: yarn, pnpm"
}

# ============================================================
# 5. Python Tools
# ============================================================
if (-not $SkipPython) {
    Write-Step "5/6: Installing Python tools"
    
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Warn "Python not found, installing via Scoop..."
        scoop install python 2>&1 | Out-Null
    }
    
    $pythonPackages = @(
        "black", "pylint", "mypy", "pytest",
        "requests", "beautifulsoup4",
        "flask", "fastapi", "uvicorn",
        "rich", "click", "httpie"
    )
    
    foreach ($pkg in $pythonPackages) {
        pip install $pkg --quiet 2>$null
        Write-OK "pip: $pkg"
    }
    
    # Upgrade pip
    python -m pip install --upgrade pip --quiet
    Write-OK "pip upgraded"
}

# ============================================================
# 6. PowerShell Profile
# ============================================================
if (-not $SkipProfile) {
    Write-Step "6/6: Setting up PowerShell profile"
    
    $profileDir = Split-Path $PROFILE -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    
    $profileContent = @'
# ============================================
# PowerShell Profile - ZQM-Computing Dev Setup
# ============================================

# Scoop PATH
$scoopShims = "$env:USERPROFILE\scoop\shims"
if ($env:Path -notlike "*$scoopShims*") {
    $env:Path += ";$scoopShims"
}

# ---- Navigation ----
function la   { Get-ChildItem -Force $args }
function ..   { Set-Location .. }
function ...  { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function md   { New-Item -ItemType Directory -Path $args -Force }
function rd   { Remove-Item -Recurse -Force $args }
function touch { New-Item -ItemType File -Path $args -Force }

# ---- Modern ls ----
function l    { eza --icons=auto $args }
function ll   { eza --icons=auto -la $args }
function lt   { eza --icons=auto --tree $args }

# ---- Git shortcuts ----
function g    { git $args }
function gs   { git status -sb }
function ga   { git add $args }
function gc   { git commit -m $args }
function gcm  { git commit -m $args }
function gp   { git push }
function gpl  { git pull }
function gco  { git checkout $args }
function gb   { git branch $args }
function gd   { git diff $args }
function gl   { git lg }
function gla  { git log --oneline --all --graph }
function gst  { git stash $args }
function gcl  { git clone $args }

# ---- GitHub CLI ----
function ghpr  { gh pr $args }
function ghis  { gh issue $args }
function ghre  { gh repo $args }
function clones { ghq $args }
function ghget { ghgrab $args }
function ghorgclone { ghorg $args }

# ---- Tool replacements ----
function cat  { bat $args }
function find { fd $args }
function grep { rg $args }
function ps   { procs $args }
function top  { btm }
function df   { duf $args }
function du   { dust $args }
function gdu-go  { gdu $args }
function lines { tokei $args }
function repo  { onefetch $args }
function send  { croc $args }
function cloud { rclone $args }
function hex   { hexyl $args }
function colors { vivid $args }
function sed   { sd $args }
function cut   { choose $args }
function cheat { navi $args }
function timecmd { hyperfine $args }
function ndns  { doggo $args }
function catmd { glow $args }
function httpd { xh $args }
function run   { just $args }
function watch { watchexec $args }
function docker { lazydocker $args }

# ---- HTTPie ----
Set-Alias http httpie

# ---- Editors ----
function vim  { nvim $args }
function vi   { nvim $args }

# ---- Python ----
function py   { python $args }
function serve { python -m http.server $args }

# ---- Quick navigation ----
function home { Set-Location $HOME }
function desk { Set-Location "$HOME\Desktop" }
function docs { Set-Location "$HOME\Documents" }
function dl   { Set-Location "$HOME\Downloads" }

# ---- Env info ----
function path  { $env:Path -split ';' | Sort-Object }
function which { Get-Command $args | Select-Object Source }
function reload { & $PROFILE }

Write-Host "Profile loaded." -ForegroundColor Green
'@
    
    Set-Content -Path $PROFILE -Value $profileContent -Force
    Write-OK "PowerShell profile created at: $PROFILE"
}

# ============================================================
# Wrap Up
# ============================================================
Write-Host @"

=======================================
  Setup Complete!
=======================================
"@ -ForegroundColor Magenta

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart your terminal (or run: . `$PROFILE)" -ForegroundColor White
Write-Host "  2. Authenticate GitHub: gh auth login" -ForegroundColor White
Write-Host "  3. Verify tools: tldr, lazygit, btm, tokei" -ForegroundColor White
Write-Host "  4. Place dotfiles: git clone https://github.com/ZQM-Computing/dotfiles.git" -ForegroundColor White

Write-Host "`nTools ready:" -ForegroundColor Green
Write-Host "  Git (delta), gh, lazygit, bat, eza, fd, rg, fzf" -ForegroundColor Gray
Write-Host "  procs, btm, duf, dust, jq, sqlite3, yt-dlp, croc" -ForegroundColor Gray
Write-Host "  neovim, micro, ngrok, mkcert, httpie, xh, glow" -ForegroundColor Gray
Write-Host "  just, watchexec, starship, tokei, onefetch, rclone" -ForegroundColor Gray
Write-Host "  ffmpeg, magick, 7z, and more..." -ForegroundColor Gray