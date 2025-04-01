#!/bin/bash

set -e  # 遇到错误立即退出
set -u  # 使用未定义的变量时报错

# 定义颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取脚本所在目录的绝对路径
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# 打印信息
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# 打印错误
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 打印警告
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 打印成功
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 检测操作系统
detect_os() {
    if [ "$(uname)" == "Darwin" ]; then
        echo "macos"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        if grep -q Microsoft /proc/version; then
            echo "wsl"
        else
            echo "linux"
        fi
    else
        echo "windows"
    fi
}

# 创建备份
backup_file() {
    local file="$1"
    if [ -e "$file" ]; then
        local backup_path="$BACKUP_DIR$(dirname "$file")"
        mkdir -p "$backup_path"
        mv "$file" "$backup_path/"
        success "已备份: $file -> $backup_path/$(basename "$file")"
    fi
}

# 创建符号链接
create_symlink() {
    local src="$1"
    local dst="$2"
    
    if [ -e "$dst" ]; then
        backup_file "$dst"
    fi
    
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    success "创建符号链接: $dst -> $src"
}

# 配置Git
setup_git() {
    log "配置Git..."
    
    # 复制Git配置文件
    create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    create_symlink "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
    
    # 提示用户配置Git个人信息
    if ! git config --global user.name >/dev/null 2>&1; then
        warn "请配置Git用户名:"
        read -r git_name
        git config --global user.name "$git_name"
    fi
    
    if ! git config --global user.email >/dev/null 2>&1; then
        warn "请配置Git邮箱:"
        read -r git_email
        git config --global user.email "$git_email"
    fi
}

# 配置Shell
setup_shell() {
    log "配置Shell..."
    
    # 检测默认shell
    local shell_type="$(basename "$SHELL")"
    local rc_file
    
    case "$shell_type" in
        "bash")
            rc_file="$HOME/.bashrc"
            ;;
        "zsh")
            rc_file="$HOME/.zshrc"
            ;;
        *)
            warn "不支持的shell类型: $shell_type"
            return
            ;;
    esac
    
    # 备份现有的shell配置
    backup_file "$rc_file"
    
    # 添加shell配置
    echo "# Dotfiles Shell配置" > "$rc_file"
    echo "source \"$DOTFILES_DIR/shell/aliases.sh\"" >> "$rc_file"
    echo "source \"$DOTFILES_DIR/shell/functions.sh\"" >> "$rc_file"
    
    # 重新加载shell配置
    source "$rc_file"
}

# 配置Vim
setup_vim() {
    log "配置Vim..."
    
    # 创建必要的目录
    mkdir -p "$HOME/.vim/"{undo,swap,backup}
    
    # 安装配置文件
    create_symlink "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"
}

# 配置VSCode
setup_vscode() {
    log "配置VSCode..."
    
    local vscode_config_dir
    case "$(detect_os)" in
        "macos")
            vscode_config_dir="$HOME/Library/Application Support/Code/User"
            ;;
        "linux" | "wsl")
            vscode_config_dir="$HOME/.config/Code/User"
            ;;
        "windows")
            vscode_config_dir="$APPDATA/Code/User"
            ;;
    esac
    
    if [ -d "$vscode_config_dir" ]; then
        create_symlink "$DOTFILES_DIR/vscode/settings.json" "$vscode_config_dir/settings.json"
        create_symlink "$DOTFILES_DIR/vscode/extensions.json" "$vscode_config_dir/extensions.json"
        
        # 安装扩展
        if command -v code >/dev/null 2>&1; then
            log "安装VSCode扩展..."
            bash "$DOTFILES_DIR/vscode/install_extensions.sh"
        else
            warn "未找到VSCode命令行工具，跳过扩展安装"
        fi
    else
        warn "未找到VSCode配置目录，跳过VSCode配置"
    fi
}

# 配置SSH
setup_ssh() {
    log "配置SSH..."
    
    # 创建SSH配置目录
    mkdir -p "$HOME/.ssh/"{config.d,control}
    chmod 700 "$HOME/.ssh"
    
    # 复制SSH配置模板
    if [ ! -f "$HOME/.ssh/config" ]; then
        cp "$DOTFILES_DIR/ssh/config.template" "$HOME/.ssh/config"
        chmod 600 "$HOME/.ssh/config"
        success "已创建SSH配置文件"
    else
        warn "SSH配置文件已存在，跳过创建"
    fi
}

# 配置 ghostty
configure_ghostty() {
    log "配置ghostty..."
    
    # 复制ghostty配置模板
    if [ ! -f "$HOME/.ghostty/config.json" ]; then
        mkdir -p "$HOME/.ghostty"
        cp "$DOTFILES_DIR/ghostty/config.json" "$HOME/.ghostty/config.json"
        chmod 600 "$HOME/.ghostty/config.json"
        success "已创建ghostty配置文件"
    else
        warn "ghostty配置文件已存在，跳过创建"
    fi

    # 复制ghostty配置文件
    if [ ! -f "$HOME/.config/ghostty/config" ]; then
        mkdir -p "$HOME/.config/ghostty"
        cp "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
        chmod 600 "$HOME/.config/ghostty/config"
        success "已创建ghostty主配置文件"
    else
        warn "ghostty主配置文件已存在，跳过创建"
    fi

    # 创建符号链接以确保配置文件生效
    if [ ! -L "$HOME/.ghostty/config" ] && [ ! -f "$HOME/.ghostty/config" ]; then
        ln -s "$HOME/.config/ghostty/config" "$HOME/.ghostty/config" 
        success "已创建ghostty配置符号链接"
    else
        warn "ghostty配置符号链接已存在，跳过创建"
    fi

    log "ghostty配置完成"
}

# 主安装流程
main() {
    local os_type
    os_type=$(detect_os)
    
    log "检测到操作系统类型: $os_type"
    log "开始安装..."
    
    # 创建备份目录
    mkdir -p "$BACKUP_DIR"
    
    # 安装配置
    setup_git
    setup_shell
    setup_vim
    setup_vscode
    setup_ssh
    configure_ghostty
    
    success "安装完成！"
    warn "备份文件位置: $BACKUP_DIR"
    warn "请重新启动终端以应用所有更改"
}

# 执行主函数
main "$@"