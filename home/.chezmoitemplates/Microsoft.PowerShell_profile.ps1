# PowerShell 配置文件

# 设置别名
Set-Alias -Name vim -Value nvim
Set-Alias -Name g -Value git

# 自定义提示符
function prompt {
    $currentPath = (Get-Location).Path
    $host.UI.RawUI.WindowTitle = $currentPath
    return "PS $currentPath> "
}

# 常用函数
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# 导入模块
# Import-Module posh-git
# Import-Module oh-my-posh
# Set-PoshPrompt -Theme paradox

# 设置编码为 UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[System.Console]::InputEncoding = [System.Text.Encoding]::UTF8

# 设置历史记录
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# 自动补全
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# 显示时间
function Get-TimeStamp {
    return "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]"
}

# 添加到 PATH
# $env:Path += ";C:\Users\zhiyue\bin"

# 设置代理（如需要）
# $env:http_proxy = "http://127.0.0.1:7890"
# $env:https_proxy = "http://127.0.0.1:7890"

# 欢迎信息
Write-Host "Welcome to PowerShell!" -ForegroundColor Green
Write-Host "Current time: $(Get-TimeStamp)" -ForegroundColor Yellow

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
