#!/usr/bin/env pwsh

# 检查 Scoop 是否已安装
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Scoop..."
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# 安装常用软件包
scoop install git
scoop install neovim
scoop install ripgrep
scoop install fd
scoop install bat

# 可以添加更多您需要的软件包
