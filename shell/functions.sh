#!/bin/bash

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 提取各种压缩文件
extract() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)          echo "'$1' 无法识别的文件格式" ;;
        esac
    else
        echo "'$1' 不是一个有效文件"
    fi
}

# 创建备份文件
backup() {
    cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
}

# 快速查找文件
ff() {
    find . -type f -name "*$1*"
}

# 快速查找目录
fd() {
    find . -type d -name "*$1*"
}

# 在文件中搜索文本
search() {
    grep -r "$1" .
}

# 显示目录大小
dirsize() {
    du -sh "${1:-.}"
}

# 创建并进入临时目录
tmpd() {
    local dir
    dir=$(mktemp -d)
    echo "创建临时目录: $dir"
    cd "$dir" || exit
}

# Git相关函数
# 切换到main或master分支
gmaster() {
    if git show-ref --verify --quiet refs/heads/main; then
        git checkout main
    else
        git checkout master
    fi
}

# 创建新分支并切换
gcb() {
    git checkout -b "$1"
}

# 删除已合并的分支
gclean() {
    git branch --merged | grep -v "\*" | xargs -n 1 git branch -d
}

# 显示Git仓库状态概览
gstatus() {
    echo "==== 分支信息 ===="
    git branch -v
    echo
    echo "==== 状态 ===="
    git status -s
    echo
    echo "==== 最近提交 ===="
    git log --oneline -n 5
}

# 网络相关函数
# 检查端口是否开放
port() {
    nc -zv "$1" "$2"
}

# 显示HTTP状态码
httpstatus() {
    curl -sL -w "%{http_code}\\n" "$1" -o /dev/null
}

# 开发相关函数
# 创建Python虚拟环境
mkvenv() {
    python -m venv .venv
    source .venv/bin/activate
    pip install --upgrade pip
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    fi
}

# 显示PATH环境变量（每行一个）
showpath() {
    echo "$PATH" | tr ':' '\n'
}

# 快速HTTP服务器
serve() {
    local port="${1:-8000}"
    python -m http.server "$port"
}

# 显示当前目录的Git忽略状态
check_gitignore() {
    git check-ignore -v *
}

# 压缩目录
compress() {
    local target="${1%/}"
    tar czf "${target}.tar.gz" "$target"
}