#!/bin/bash

set -e  # 遇到错误立即退出
set -u  # 使用未定义的变量时报错

# 定义颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 获取脚本所在目录的绝对路径
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# 打印信息
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# 打印警告
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 打印错误
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 打印成功
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 检查是否有未提交的更改
check_uncommitted_changes() {
    if ! git -C "$DOTFILES_DIR" diff --quiet HEAD; then
        warn "检测到未提交的更改。"
        warn "请先提交或储藏您的更改。"
        exit 1
    fi
}

# 更新仓库
update_repository() {
    log "正在更新dotfiles仓库..."
    
    # 切换到dotfiles目录
    cd "$DOTFILES_DIR"
    
    # 获取远程更改
    log "拉取远程更改..."
    git fetch origin
    
    # 获取当前分支
    local current_branch
    current_branch=$(git symbolic-ref --short HEAD)
    
    # 检查是否有更新
    if git diff --quiet "$current_branch" "origin/$current_branch"; then
        success "dotfiles已是最新状态"
        return 0
    fi
    
    # 更新当前分支
    log "合并远程更改..."
    if git merge "origin/$current_branch"; then
        success "成功更新到最新版本"
    else
        error "合并更改时发生冲突"
    fi
}

# 重新运行安装脚本
run_installer() {
    log "重新运行安装脚本..."
    
    if [ -f "$DOTFILES_DIR/install.sh" ]; then
        bash "$DOTFILES_DIR/install.sh"
    else
        error "未找到安装脚本"
    fi
}

# 更新VSCode扩展
update_vscode_extensions() {
    log "更新VSCode扩展..."
    
    if command -v code >/dev/null 2>&1; then
        if [ -f "$DOTFILES_DIR/vscode/install_extensions.sh" ]; then
            bash "$DOTFILES_DIR/vscode/install_extensions.sh"
        else
            warn "未找到VSCode扩展安装脚本"
        fi
    else
        warn "未找到VSCode命令行工具，跳过扩展更新"
    fi
}

# 主更新流程
main() {
    log "开始更新dotfiles..."
    
    # 检查Git仓库
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        error "未找到Git仓库，请确保这是一个Git仓库"
    fi
    
    # 检查未提交的更改
    check_uncommitted_changes
    
    # 更新仓库
    update_repository
    
    # 重新运行安装脚本
    run_installer
    
    # 更新VSCode扩展
    update_vscode_extensions
    
    success "更新完成！"
    warn "请重新启动终端以应用所有更改"
}

# 执行主函数
main "$@"