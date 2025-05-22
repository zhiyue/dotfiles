param(
    [Parameter(Mandatory=$true)]
    [string]$Commit,
    
    [Parameter(Mandatory=$false)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$false)]
    [string]$AgeKeyFile,
    
    [Parameter(Mandatory=$false)]
    [switch]$UsePassphrase
)

# 保存当前工作目录
$originalLocation = Get-Location

try {
    # 获取源目录
    $sourceDir = $(chezmoi source-path)

    # 切换到源目录
    Set-Location $sourceDir
    Write-Host "探索仓库中可能的文件路径..." -ForegroundColor Cyan

    # 检查是否有 .chezmoiroot 配置
    $chezmoiRoot = ""
    $chezmoiRootPath = Join-Path $sourceDir ".chezmoiroot"
    if (Test-Path $chezmoiRootPath) {
        $chezmoiRoot = Get-Content $chezmoiRootPath -Raw
        $chezmoiRoot = $chezmoiRoot.Trim()
        Write-Host "检测到 .chezmoiroot 配置: $chezmoiRoot" -ForegroundColor Cyan
    }

    # 列出提交中的所有文件
    $allFiles = git ls-tree -r --name-only $Commit

    # 如果未提供文件路径，则尝试搜索加密文件
    if (-not $FilePath) {
        $encryptedFiles = $allFiles | Where-Object { $_ -like "*encrypted*" -or $_ -like "*.age" }
        
        if (-not $encryptedFiles) {
            Write-Host "错误: 在提交 $Commit 中找不到加密文件" -ForegroundColor Red
            Write-Host "仓库中的所有文件:" -ForegroundColor Yellow
            $allFiles | ForEach-Object { Write-Host "  $_" }
            return
        }
        
        Write-Host "找到以下可能的加密文件:" -ForegroundColor Green
        $encryptedFiles | ForEach-Object { Write-Host "  $_" }
        
        # 选择文件
        $FilePath = if ($encryptedFiles.Count -eq 1) {
            $encryptedFiles
        } else {
            Write-Host "发现多个加密文件，请选择需要解密的文件:" -ForegroundColor Yellow
            for ($i=0; $i -lt $encryptedFiles.Count; $i++) {
                Write-Host "[$i] $($encryptedFiles[$i])"
            }
            $selection = Read-Host "请输入文件编号"
            $encryptedFiles[$selection]
        }
    }

    Write-Host "选择的文件路径: $FilePath" -ForegroundColor Cyan

    # 查找对应的源路径
    $sourcePath = $null

    # 判断是否是目标路径（通常以~ 或 系统路径开头）
    $isTargetPath = $FilePath.StartsWith("$env:USERPROFILE") -or $FilePath.StartsWith("~") -or [System.IO.Path]::IsPathRooted($FilePath)

    if ($isTargetPath) {
        # 1. 如果是目标路径，使用 chezmoi 查找源路径
        try {
            # 将路径转换为相对于用户主目录（如果适用）
            $relativePath = $FilePath
            if ($FilePath.StartsWith("$env:USERPROFILE")) {
                $relativePath = $FilePath -replace [regex]::Escape("$env:USERPROFILE"), "~"
            }
            $relativePath = $relativePath -replace "\\", "/"
            $relativePath = $relativePath -replace "^~[/]?", "~/"
            
            Write-Host "尝试通过 chezmoi 查找源路径: $relativePath" -ForegroundColor Cyan
            $chezmoiSourcePath = & chezmoi source-path "$relativePath" 2>$null
            
            if ($LASTEXITCODE -eq 0 -and $chezmoiSourcePath) {
                # 获取相对于源目录的路径
                $sourcePath = $chezmoiSourcePath -replace [regex]::Escape($sourceDir), ""
                $sourcePath = $sourcePath.TrimStart("\", "/")
                Write-Host "找到源路径: $sourcePath" -ForegroundColor Green
                
                # 获取源文件可能的格式
                $candidatePaths = @()
                $candidatePaths += $sourcePath
                
                # 如果有 .chezmoiroot 配置，添加相应的路径
                if ($chezmoiRoot) {
                    if (-not $sourcePath.StartsWith($chezmoiRoot)) {
                        $candidatePaths += Join-Path $chezmoiRoot $sourcePath -replace "\\", "/"
                    }
                } else {
                    # 默认添加 home 路径
                    $candidatePaths += "home/$sourcePath"
                }
                
                # 验证路径
                $sourcePath = $null
                foreach ($path in $candidatePaths) {
                    $testResult = & git show "$Commit`:$path" > $null 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        $sourcePath = $path
                        Write-Host "在提交中找到有效路径: $sourcePath" -ForegroundColor Green
                        break
                    }
                }
                
                # 如果还是找不到，添加.age 后缀尝试
                if (-not $sourcePath) {
                    foreach ($path in $candidatePaths) {
                        # 尝试带 .age 后缀的路径
                        $agePath = $path
                        if (-not $path.EndsWith(".age")) {
                            $agePath = "$path.age"
                        }
                        $testResult = & git show "$Commit`:$agePath" > $null 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            $sourcePath = $agePath
                            Write-Host "在提交中找到有效的加密路径: $sourcePath" -ForegroundColor Green
                            break
                        }
                        
                        # 尝试 encrypted_ 前缀
                        $encryptedPath = $path -replace "/([^/]+)$", "/encrypted_`$1"
                        if (-not $encryptedPath.EndsWith(".age")) {
                            $encryptedPath = "$encryptedPath.age"
                        }
                        $testResult = & git show "$Commit`:$encryptedPath" > $null 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            $sourcePath = $encryptedPath
                            Write-Host "在提交中找到有效的加密路径: $sourcePath" -ForegroundColor Green
                            break
                        }
                    }
                }
            }
        } catch {
            Write-Host "通过 chezmoi 查找源路径失败: $_" -ForegroundColor Yellow
        }
    } else {
        # 2. 如果是源路径，直接验证
        $testResult = & git show "$Commit`:$FilePath" > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            $sourcePath = $FilePath
            Write-Host "提供的源路径有效: $sourcePath" -ForegroundColor Green
        }
    }

    # 3. 如果仍未找到源路径，尝试基本的路径变体
    if (-not $sourcePath) {
        Write-Host "未找到直接匹配的源路径，尝试常见路径变体..." -ForegroundColor Yellow
        
        # 准备路径变体
        $pathVariants = @()
        $pathVariants += $FilePath
        $pathVariants += $FilePath -replace "\\", "/"
        $pathVariants += "home/" + ($FilePath -replace "\\", "/")
        if ($FilePath -notlike "dot_*" -and $FilePath -notlike ".*") {
            $fileName = Split-Path $FilePath -Leaf
            $fileDir = Split-Path $FilePath -Parent
            if ($fileName -like ".*") {
                $dotName = "dot_" + ($fileName -replace "^\.", "")
                $dotPath = if ($fileDir) { "$fileDir/$dotName" } else { $dotName }
                $pathVariants += $dotPath
                $pathVariants += "home/$dotPath"
            }
        }
        
        # 尝试各种变体
        foreach ($path in $pathVariants) {
            $testResult = & git show "$Commit`:$path" > $null 2>&1
            if ($LASTEXITCODE -eq 0) {
                $sourcePath = $path
                Write-Host "找到有效的源路径: $sourcePath" -ForegroundColor Green
                break
            }
            
            # 尝试 encrypted + .age 变体
            if (-not $path.EndsWith(".age")) {
                $agePath = "$path.age"
                $testResult = & git show "$Commit`:$agePath" > $null 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $sourcePath = $agePath
                    Write-Host "找到有效的加密源路径: $sourcePath" -ForegroundColor Green
                    break
                }
            }
            
            # 尝试 encrypted_ 前缀
            $encryptedPath = $path -replace "/([^/]+)$", "/encrypted_`$1"
            if (-not $encryptedPath.EndsWith(".age")) {
                $encryptedPath += ".age"
            }
            $testResult = & git show "$Commit`:$encryptedPath" > $null 2>&1
            if ($LASTEXITCODE -eq 0) {
                $sourcePath = $encryptedPath
                Write-Host "找到有效的加密源路径: $sourcePath" -ForegroundColor Green
                break
            }
        }
    }

    # 如果仍然找不到，使用原始路径
    if (-not $sourcePath) {
        Write-Host "警告: 无法找到有效的源路径，将使用原始路径: $FilePath" -ForegroundColor Yellow
        $sourcePath = $FilePath
    }

    # 准备 age 命令参数
    $ageParams = @()
    if ($UsePassphrase) {
        Write-Host "使用密码模式解密" -ForegroundColor Cyan
        $ageParams += "--passphrase"
    } elseif ($AgeKeyFile) {
        if (Test-Path $AgeKeyFile) {
            Write-Host "使用指定的密钥文件: $AgeKeyFile" -ForegroundColor Cyan
            $ageParams += "--identity=$AgeKeyFile"
        } else {
            Write-Host "错误: 指定的密钥文件不存在: $AgeKeyFile" -ForegroundColor Red
            return
        }
    } else {
        # 尝试查找默认密钥文件
        $defaultKeyFile = "$env:USERPROFILE\.config\age\keys.txt"
        if (Test-Path $defaultKeyFile) {
            Write-Host "使用默认密钥文件: $defaultKeyFile" -ForegroundColor Cyan
            $ageParams += "--identity=$defaultKeyFile"
        } else {
            Write-Host "未找到默认密钥文件，切换到密码模式" -ForegroundColor Yellow
            $ageParams += "--passphrase"
        }
    }

    # 尝试解密
    Write-Host "尝试解密: git show $Commit`:$sourcePath | age --decrypt $($ageParams -join ' ')" -ForegroundColor DarkCyan
    Write-Host "`n--- 解密内容开始 ---`n" -ForegroundColor Green

    $decryptSucceeded = $false
    try {
        # 使用管道直接连接 git show 和 age 命令
        $gitOutput = & git show "$Commit`:$sourcePath" 2>&1
        
        # 检查 git 命令是否成功
        if ($LASTEXITCODE -eq 0) {
            # 通过管道将 git 输出传给 age
            $decryptedOutput = $gitOutput | & age --decrypt @ageParams 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                # 输出解密内容
                $decryptedOutput
                $decryptSucceeded = $true
            } else {
                Write-Host "解密失败: $decryptedOutput" -ForegroundColor Red
            }
        } else {
            Write-Host "无法从 git 提交中提取文件内容: $gitOutput" -ForegroundColor Red
        }
        
        # 如果第一次尝试失败并且没有使用密码模式，则尝试密码模式
        if (-not $decryptSucceeded -and -not $UsePassphrase) {
            Write-Host "尝试使用密码模式重新解密..." -ForegroundColor Yellow
            
            # 重新获取 git 内容
            $gitOutput = & git show "$Commit`:$sourcePath" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                $decryptedOutput = $gitOutput | & age --decrypt --passphrase 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    # 输出密码模式下解密的内容
                    $decryptedOutput
                    $decryptSucceeded = $true
                } else {
                    Write-Host "密码模式解密也失败了: $decryptedOutput" -ForegroundColor Red
                }
            }
        }
    } catch {
        Write-Host "执行过程中出错: $_" -ForegroundColor Red
    }

    Write-Host "`n--- 解密内容结束 ---`n" -ForegroundColor Green

    if ($decryptSucceeded) {
        Write-Host "解密成功！" -ForegroundColor Green
    } else {
        Write-Host "所有解密尝试都失败了。" -ForegroundColor Red
        Write-Host "提示: 您可以尝试以下选项" -ForegroundColor Yellow
        Write-Host "1. 使用 -UsePassphrase 参数尝试密码模式" -ForegroundColor Yellow
        Write-Host "2. 使用 -AgeKeyFile 指定一个有效的密钥文件" -ForegroundColor Yellow
        Write-Host "3. 确认文件路径和提交 ID 是否正确" -ForegroundColor Yellow
    }
}
finally {
    # 无论脚本成功还是失败，确保切换回原始工作目录
    Write-Host "切换回原始工作目录: $originalLocation" -ForegroundColor Cyan
    Set-Location -Path $originalLocation
}