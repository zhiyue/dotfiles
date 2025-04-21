#!/usr/bin/env pwsh

# 检查 Scoop 是否已安装
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Scoop..."
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# 安装基础依赖
Write-Output "Installing basic dependencies..."
scoop install 7zip # 解压缩工具，很多包的安装都依赖它
scoop install git # 需要 git 才能添加 bucket
scoop install aria2 # 多线程下载工具，加速 Scoop 下载

# 安装常用的命令行工具
Write-Output "Installing common command line tools..."
scoop install curl # 网络请求工具
scoop install sudo # 提权工具
scoop install grep # 文本搜索工具
scoop install touch # 创建文件
scoop install sed # 文本处理工具

# 添加常用 bucket
Write-Output "Adding common Scoop buckets..."
scoop bucket add extras
scoop bucket add versions
scoop bucket add nerd-fonts
scoop bucket add java
scoop bucket add games

# 安装常用软件包
Write-Output "Installing common packages..."
scoop install neovim
scoop install ripgrep
scoop install fd
scoop install bat
scoop install posh-git
# 可以添加更多您需要的软件包


# winget install -e --id Docker.DockerDesktop

winget install starship
scoop install age