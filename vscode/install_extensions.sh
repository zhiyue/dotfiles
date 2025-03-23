#!/bin/bash

# 定义颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示信息
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# 显示成功
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 检查extensions.json是否存在
if [ ! -f "$SCRIPT_DIR/extensions.json" ]; then
    echo "错误：extensions.json 文件未找到"
    exit 1
fi

# 从extensions.json中提取扩展ID并安装
log "开始安装 VSCode 扩展..."

# 使用jq提取扩展ID（如果可用）
if command -v jq >/dev/null 2>&1; then
    extensions=$(jq -r '.recommendations[]' "$SCRIPT_DIR/extensions.json")
else
    # 如果jq不可用，使用grep和sed
    extensions=$(grep '".*"' "$SCRIPT_DIR/extensions.json" | \
                grep -v "recommendations" | \
                sed 's/[",]//g' | \
                sed 's/^[ \t]*//')
fi

# 统计
total=0
success_count=0
failed_count=0

# 安装扩展
while IFS= read -r extension; do
    # 跳过空行和注释
    [[ -z "$extension" || "$extension" =~ ^[[:space:]]*// ]] && continue
    
    ((total++))
    log "正在安装: $extension"
    
    if code --install-extension "$extension" --force > /dev/null 2>&1; then
        success "已安装: $extension"
        ((success_count++))
    else
        echo "警告: 安装失败: $extension"
        ((failed_count++))
    fi
done <<< "$extensions"

# 显示结果
echo
echo "安装完成！"
echo "总计: $total"
echo "成功: $success_count"
echo "失败: $failed_count"

# 提示重启VSCode
if [ $success_count -gt 0 ]; then
    echo
    echo "请重启 VSCode 以激活新安装的扩展。"
fi