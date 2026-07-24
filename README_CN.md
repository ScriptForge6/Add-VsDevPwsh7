<div align="center">

# Add-VsDevPwsh7

PowerShell 7 Developer Terminal for Visual Studio

自动化 `PowerShell 5.1` 脚本：适用于 `Visual Studio` 的 **PowerShell 7 开发者终端**（仅支持 **Windows 10 / Windows 11 x64**）

[English](README_EN.md) | 简体中文

</div>

## ✨ 项目介绍
Visual Studio 官方开发者终端仅提供 CMD / PowerShell 5.1，**不存在原生 PowerShell 7 版本**。

本脚本借助 `vswhere` 自动检索本机 Visual Studio，一键生成可加载完整 MSVC 编译环境的 PowerShell 7 启动脚本；
可选自动注册到 Windows 注册表、写入 Windows Terminal 配置，告别手动配置环境变量、手写快捷方式。

## 🚩 核心特性
- 通过 vswhere 自动定位 Visual Studio / Visual Studio Build Tools
- 生成独立启动脚本，原生调用官方 `Launch-VsDevShell.ps1`，开发环境与官方终端完全一致
- 可选：注册至 Windows「设置 → 应用」，自带卸载指令
- 可选：自动向 Windows Terminal 新增独立终端配置项
- 完善环境校验：拦截 Linux、macOS、32 位进程，提前输出友好错误
- 兼容 PowerShell 原生 `-InformationAction` 公共参数，额外支持自定义 `-Silent` 静默模式
- 完全遵循 PowerShell 脚本开发规范，**原生支持 `Get-Help` 查阅完整文档**
- 可通过 **PSGallery 直接在线安装**
- 采用 Apache 2.0 开源协议

## 📦 前置依赖
1. Windows 10 / Windows 11 x64
2. 已安装 Visual Studio 或 Visual Studio Build Tools
3. 预先安装 PowerShell 7 (pwsh)

## ⚡ 快速上手
### 方式一：从 PSGallery 安装（推荐，自动版本管理）
以管理员 PowerShell 执行：
```powershell
Install-Script Add-VsDevPwsh7 -Force
```
安装完成后直接调用：
```powershell
Add-VsDevPwsh7
```

### 方式二：手动下载脚本
1. Clone 仓库或直接下载脚本 `Add-VsDevPwsh7.ps1`
2. 使用 **64位 PowerShell 5.1 或 PowerShell 7** 执行

最简用法（仅生成启动脚本，不修改注册表与 Windows Terminal）
```powershell
.\Add-VsDevPwsh7.ps1
```

完整示例：生成脚本 + 注册到系统应用列表 + 添加 Windows Terminal 配置
```powershell
Add-VsDevPwsh7 -RegisterToRegistry -AddToWindowsTerminal -RepoDir "D:\YourCodeFolder"
```

## 📖 完整参数文档
> 所有参数说明内置在脚本中，无需在线查阅文档
```powershell
# 查看完整帮助信息
Get-Help Add-VsDevPwsh7 -Full

# 仅列出全部参数说明
Get-Help Add-VsDevPwsh7 -Parameter *
```

## ❓ 常见提示
- 写入 HKLM 注册表项**需要管理员权限**；权限不足将自动跳过注册流程，不会直接崩溃
- 脚本具备幂等性，多次重复运行不会产生大量重复配置
- 若无需启动后自动跳转代码目录，可不传入 `-RepoDir`，将使用预设默认路径

## 🚪 退出码定义
| 退出码 | 含义 |
|--------|------|
| `-1`   | 操作系统/进程架构不匹配 |
| `1`    | 指定路径下 vswhere.exe 不存在 |
| `2`    | 目标输出目录无读写权限 |

## 📄 License
Apache License 2.0  
Copyright (c) 2026 ScriptForge



