# Windows Dev Setup

Automated bootstrap script to set up a complete Windows development environment from scratch.

## Quick Start

```powershell
# Run this in PowerShell (as admin recommended)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
iex "& {$(iwr -useb https://get.scoop.sh)} -RunAsAdmin"

# Then clone and run
git clone https://github.com/ZQM-Computing/dev-setup.git
.\dev-setup\bootstrap.ps1
```

## What Gets Installed

### Package Manager
- **Scoop** - CLI package manager for Windows

### Version Control
- **Git** with delta diff viewer, aliases, and optimized settings
- **GitHub CLI** (gh) for PRs, issues, repos
- **lazygit** - Terminal UI for git
- **ghq** - Repository management
- **ghgrab** - Download GitHub releases
- **ghorg** - Clone entire org/user repos

### Development Runtimes (via npm/pip)
- Node.js + npm
- TypeScript, ESLint, Prettier
- Yarn, pnpm
- Python + pip
- black, pylint, mypy, pytest
- Flask, FastAPI, uvicorn

### CLI Tool Replacements
| Tool | Replaces | Purpose |
|------|----------|---------|
| bat | cat | Syntax-highlighted file viewer |
| eza | ls | Modern ls with icons |
| fd | find | Fast file search |
| ripgrep (rg) | grep | Fast code search |
| procs | ps | Modern process viewer |
| bottom (btm) | top | System monitor |
| duf | df | Disk usage |
| dust | du | Intuitive disk usage |
| delta | diff | Side-by-side diffs |
| sd | sed | Find & replace |
| choose | cut | Column selection |

### Productivity
- **neovim** - Modern Vim
- **micro** - Terminal editor
- **fzf** - Fuzzy finder
- **zoxide** - Smarter cd
- **broot** - Directory tree navigator
- **tldr** - Simplified man pages
- **navi** - Interactive cheatsheet
- **just** - Command runner (Make alternative)
- **watchexec** - File watcher
- **hyperfine** - Command benchmarking

### Network & Data
- curl, wget, httpie, xh
- **jq** - JSON processor
- **sqlite3** - Database CLI
- **doggo** - DNS lookup
- **ngrok** - Tunnel localhost
- **mkcert** - Local HTTPS certs

### Media & File Transfer
- **ffmpeg** - Media processing
- **ImageMagick** + **Ghostscript** - Image manipulation
- **yt-dlp** - Video downloader
- **croc** - Secure file transfer
- **rclone** - Cloud storage sync

### System
- 7zip, gzip
- which, diffutils, less
- vcredist2022

## Post-Install

After setup completes, open a new PowerShell terminal. Your profile with all aliases will be loaded automatically.

```powershell
# Verify tools
gh auth login          # Authenticate with GitHub
lazygit                # Launch git TUI
btm                    # System monitor
tokei                  # Count lines of code
onefetch               # Git repo info
```

## Scoop Buckets Added


## Related Repositories

- [ZQM-AI-Council](https://github.com/ZQM-Labs/ZQM-AI-Council) — Multi-model AI council runtime
- [Ollama Bridge](https://github.com/ZQM-Labs/ollama-bridge) — Ollama integration layer
- [ZQM-Labs](https://github.com/ZQM-Labs/ZQM-Labs) — Cross-org mesh utilities

- main, extras, versions
- nerd-fonts, java, nonportable