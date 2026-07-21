<#PSScriptInfo

.VERSION 0.1.3

.GUID af7c8e7f-7575-442b-a1ea-ca749eedd0d8

.AUTHOR ScriptForge

.COMPANYNAME ScriptForge

.COPYRIGHT (c) 2026 ScriptForge. All rights reserved.

.TAGS VisualStudio, PowerShell7, Developer, Terminal

.LICENSEURI https://github.com/ScriptForge6/Add-VsDevPwsh7/blob/master/LICENSE.txt

.PROJECTURI https://github.com/ScriptForge6/Add-VsDevPwsh7

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
# v0.2.0-pre
- add:
    - Exit code specification update:
      - `-1` = Operating system mismatch
      - `3` = Failed to acquire administrator privileges
    - New parameter added:
      - -Pwsh7Path
- 新增功能：
    - 退出码定义新增：
      - `-1` = 操作系统不匹配
      - `3` = 管理员权限获取失败
    - 新增参数：
      - -Pwsh7Path

.PRIVATEDATA

#>

<#
.SYNOPSIS
Auto PS5.1 Script: PowerShell 7 Developer Terminal for Visual Studio (Win10/11 Only)
自动化PowerShell 5.1脚本：适用于Visual Studio的PowerShell 7开发终端（仅Windows10/11可用）

.DESCRIPTION
Locate installed Visual Studio instances via vswhere, generate a startup script that loads complete VS build environment for PowerShell 7.
Supports registering to Windows Registry and adding dedicated profile to Windows Terminal.
通过 vswhere 检索本机已安装的 Visual Studio，生成加载完整编译环境的 PowerShell 7 启动脚本，支持写入注册表注册程序、向 Windows Terminal 添加专属配置项。

.PARAMETER Vswhere
Optional. Specifies the path to vswhere.exe. Defaults to the official default installation path of vswhere.
可选，指定 vswhere.exe 文件路径，默认使用 vswhere 官方默认安装路径。

.PARAMETER OutDir
Optional. Directory path for the final generated ps1 script. Defaults to C:\VsDevWithPwsh7.
可选，指定生成后的 ps1 脚本存放目录，默认路径为 C:\VsDevWithPwsh7。

.PARAMETER RepoDir
Optional. When specified, automatically navigates to this directory when launching the VS PowerShell 7 Developer Terminal.
可选，指定后会在启动 VS PowerShell 7 开发者终端时，自动进入该目录。

.PARAMETER Pwsh7Path
Optional. When specified, searches for PowerShell 7 at the given path for use in the registry and Windows Terminal's settings.json. Defaults to the default installation location of PowerShell 7.
可选，指定后会在该路径寻找 Powershell 7 ，以供注册表与 Windows Terminal 的 settings.json 使用，默认为 Powershell 7 的默认安装位置。

.PARAMETER RegisterToRegistry
Optional. When specified, registers the VS PowerShell 7 Developer Terminal to Windows Registry as an installed application.
可选，指定后会将 VS PowerShell 7 开发者终端写入注册表，注册为已安装程序。

.PARAMETER RegistryName
Optional. Specifies the display name shown in Windows Registry and Apps list. Defaults to "Developer PowerShell 7 for VS".
可选，指定在注册表与软件列表中展示的名称，默认为“Developer PowerShell 7 for VS”。

.PARAMETER AddToWindowsTerminal
Optional. When specified, adds the VS PowerShell 7 Developer Terminal profile to Windows Terminal's settings.json.
可选，指定后会将 VS PowerShell 7 开发者终端配置写入 Windows Terminal 的 settings.json。

.PARAMETER WtProfileName
Optional. Specifies the display name used in Windows Terminal. If not provided, the value of -RegistryName will be used instead.
可选，指定在 Windows Terminal 中显示的名称；若未传入该参数，则复用 -RegistryName 的值。

.PARAMETER Guid
Optional. Specifies the unique GUID identifier for the Windows Terminal profile. A random GUID will be generated if omitted.
可选，指定 Windows Terminal 配置项的唯一标识 GUID，未传入时将随机生成。
#>


#一、参数列表


#1.参数列表

[CmdletBinding()]
param(
    # 基础通用参数
    [string]$Vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe",
    [string]$OutDir = "C:\VsDevWithPwsh7",
    [string]$RepoDir = (Join-Path $env:USERPROFILE "source\repos"),
    

    # 注册表注册相关参数
    [switch]$RegisterToRegistry,
    [string]$RegistryName = "Developer PowerShell 7 for VS",

    # Windows Terminal 配置相关参数
    [switch]$AddToWindowsTerminal,
    [string]$WtProfileName = $RegistryName,
    [string]$Guid,

    # 注册表注册、 Windows Terminal 共用参数
    [string]$Pwsh7Path = "${env:ProgramFiles}\PowerShell\7\pwsh.exe"
)


#一、初始化


#1.初始化输出等级

$InformationPreference = 'Continue'

#2.检查系统

# 获取PS总版本
$PSVersion = $PSVersionTable.PSVersion.Major

# 检查版本
if($PSVersion -le 5) {
    Write-Information "OS check passed
操作系统检测通过"
} elseif($PSVersion -gt 5) {
    if ($IsWindows) {
        Write-Information "OS check passed
操作系统检测通过"
    } elseif ($IsLinux) {
        Write-Error "OS check failed. Current OS: Linux
操作系统检测未通过，目前操作系统：Linux"
        exit -1
    } elseif ($IsMacOS) {
        Write-Error "OS check failed. Current OS: macOS
操作系统检测未通过，目前操作系统：macOS"
        exit -1
    } else {
        Write-Error "OS check failed. Current OS: Unknown
操作系统检测未通过，目前操作系统：未知系统"
        exit -1
    }
}

#3.初始化变量

# 初始化Guid
if (-not $PSBoundParameters.ContainsKey('Guid')) {
    $Guid = [guid]::NewGuid().ToString("B")
}

#3.校验参数使用是否正确

# 校验函数：
function Test-ParameterDependency {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ChildName,                      # 子参数名（如 'RegistryName'）

        [Parameter(Mandatory = $true)]
        [string]$ParentName,                     # 父参数名（如 'RegisterToRegistry'）

        [Parameter(Mandatory = $true)]
        [switch]$ParentIsPresent,                # 父参数是否被指定

        [Parameter(Mandatory = $true)]
        [hashtable]$CallerBoundParameters        # 调用方的 $PSBoundParameters，用于检测子参数是否显式传入
    )
    
    if ($CallerBoundParameters.ContainsKey($ChildName) -and -not $ParentIsPresent) {
        Write-Warning "The parameter -$ChildName only takes effect when -$ParentName is specified; the input will be ignored.
参数 -$ChildName 仅在指定 -$ParentName 时生效，当前传入无效"
        return
    }
    
    return
}

# 校验-RegistryName参数
Test-ParameterDependency -ChildName 'RegistryName' -ParentName 'RegisterToRegistry' -ParentIsPresent:$RegisterToRegistry -CallerBoundParameters $PSBoundParameters

# 校验-WtProfileName参数
Test-ParameterDependency -ChildName 'WtProfileName' -ParentName 'AddToWindowsTerminal' -ParentIsPresent:$AddToWindowsTerminal -CallerBoundParameters $PSBoundParameters

# 校验-Guid参数
Test-ParameterDependency -ChildName 'Guid' -ParentName 'AddToWindowsTerminal' -ParentIsPresent:$AddToWindowsTerminal -CallerBoundParameters $PSBoundParameters

# 校验-Pwsh7Path参数
if($CallerBoundParameters.ContainsKey("Pwsh7Path") -and -not ($RegisterToRegistry -or $AddToWindowsTerminal)) {
    Write-Warning "The parameter -Pwsh7Path only takes effect when -RegisterToRegistry or -AddToWindowsTerminal is specified; the input will be ignored.
参数 -Pwsh7Path 仅在指定 -RegisterToRegistry 或 -AddToWindowsTerminal 时生效，当前传入无效"
}

#二、生成ps1文件


#1.检验Vswhere

if (-not (Test-Path $Vswhere)) {
    Write-Error "vswhere.exe not found at: $Vswhere.
在 $Vswhere 未找到 vswhere.exe。"
exit 1
}

#2.生成ps1文件

$scriptContent = @"
`$Vswhere = '$Vswhere'
if (-not (Test-Path `$Vswhere)) {
    Write-Error "vswhere.exe not found at: `$Vswhere.
在 `$Vswhere 未找到 vswhere.exe。"
}
`$vsRoot = & `$Vswhere -latest -property installationPath
if (-not `$vsRoot) {
    Write-Error "No Visual Studio instance detected.
未检测到任何 Visual Studio 安装实例。"
exit 1
}

`$devShell = Join-Path `$vsRoot "Common7\Tools\Launch-VsDevShell.ps1"
if (Test-Path `$devShell) {
    & `$devShell -SkipAutomaticLocation
}
else {
    Write-Error "DevShell script is missing.
Dev 命令行缺失。"
exit 1
}

`$repoDir = '$RepoDir'
if (Test-Path `$repoDir) {
    Set-Location `$repoDir
}
else {
    Write-Error "Repo directory does not exist, staying in current working directory.
仓库目录不存在，保持当前路径。"
exit 1
}
"@

$outputScript = Join-Path $OutDir "Start-VsDevPwsh7.ps1"
try {
    if (-not (Test-Path $OutDir)) {
        New-Item -Path $OutDir -ItemType Directory -Force | Out-Null
    }
    Set-Content -Path $outputScript -Value $scriptContent -Encoding utf8 -ErrorAction Stop
    Write-Information "Startup script generated successfully: $outputScript
开发终端启动脚本已生成"
}
catch {
    Write-Error "Failed to write script to $outputScript : $_
脚本写入失败，权限不足或目录不可写，请更换输出目录或以管理员身份运行 PowerShell"
    exit 2
}


#二、注册表注册


#注册表函数
function Register-VsDevTerminalToRegistry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        [Parameter(Mandatory = $true)]
        [string]$DisplayRegName
    )

    #1.检测权限

    $isAdmin = [Security.Principal.WindowsPrincipal]::GetCurrent().IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Start-Process powershell -ArgumentList "-File `"$ScriptPath`"" -Verb RunAs
        exit 3
    }

    #2.
}



# 清理
exit 0