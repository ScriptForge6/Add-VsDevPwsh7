<div align="center">

# Add-VsDevPwsh7

PowerShell 7 Developer Terminal for Visual Studio

**Auto `PS5.1` Script**: **PowerShell 7 Developer Terminal** for `Visual Studio` (**Win10/11** Only)

 English | [简体中文](README_CN.md)

</div>

## ✨ Introduction
The official Visual Studio Developer Terminal only provides CMD / PowerShell 5.1.
There is **no official native PowerShell 7 version**.

This script uses `vswhere` to automatically detect local Visual Studio installations, and generates a startup script for PowerShell 7 with full MSVC build environment loaded.
Optionally, you can register the entry into Windows Registry and inject dedicated profile into Windows Terminal, eliminating manual environment configuration and custom shortcuts.

## 🚩 Features
- Locate Visual Studio / Visual Studio Build Tools automatically via vswhere
- Generate standalone startup script, invoke official `Launch-VsDevShell.ps1`. The environment is identical to official developer terminal.
- Optional: Register entry into Windows Settings → Apps with built-in uninstall command
- Optional: Create dedicated profile inside Windows Terminal
- Robust environment detection: block Linux, macOS and 32-bit processes with friendly error messages
- Fully compatible with native PowerShell `-InformationAction` common parameter, with custom `-Silent` mode
- Complies with official PowerShell standards, built-in support for `Get-Help`
- Licensed under Apache 2.0

## 📦 Requirements
1. Windows 10 / Windows 11 x64
2. Visual Studio or Visual Studio Build Tools installed
3. PowerShell 7 (pwsh) installed

## ⚡ Quick Start
### Option 1: Install from PSGallery (Recommended, auto version manage)
Run PowerShell as Administrator:
```powershell
Install-Script Add-VsDevPwsh7 -Force
```
After installation, run directly:
```powershell
Add-VsDevPwsh7
```

### Option 2: Manual download
1. Clone repository or download `Add-VsDevPwsh7.ps1`
2. Run under **64-bit PowerShell 5.1 or PowerShell 7**

Minimal usage (only generate script, no registry / Windows Terminal changes):
```powershell
.\Add-VsDevPwsh7.ps1
```

Full example:
```powershell
Add-VsDevPwsh7 -RegisterToRegistry -AddToWindowsTerminal -RepoDir "D:\YourCodeFolder"
```

## 📖 Full Documentation
> All parameter descriptions are embedded inside the script
```powershell
# View full help document
Get-Help Add-VsDevPwsh7 -Full

# List all parameters only
Get-Help Add-VsDevPwsh7 -Parameter *
```
## Exit code specification
- `-1` = Operating system mismatch
- `1` = Specified vswhere.exe cannot be found
- `2` = Target output directory lacks read/write permissions

## 📄 License
Apache License 2.0  
Copyright (c) 2026 ScriptForge
