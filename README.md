# 个人 Dotfiles 配置

这个仓库包含了我的个人开发环境配置文件，支持跨平台同步（Linux、macOS 和 Windows WSL）。

## 目录结构

```
.
├── install.sh          # 主安装脚本
├── shell/             # Shell 配置 (bash/zsh)
├── git/               # Git 配置和别名
├── vscode/            # VSCode 设置和扩展
├── vim/               # Vim/Neovim 配置
├── scripts/           # 实用脚本
└── ssh/               # SSH 配置模板
```

## 特性

- 模块化组织，易于维护
- 跨平台支持 (Linux、macOS、Windows WSL)
- 安全的敏感数据处理
- 自动化安装和配置
- 完整的文档说明

## 快速开始

1. 克隆仓库：
```bash
git clone https://github.com/your-username/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. 运行安装脚本：
```bash
./install.sh
```

## 注意事项

- 安装前请先备份现有的配置文件
- 敏感数据（如 SSH 密钥）需要单独处理
- 可以根据个人需求自定义配置

## 许可

MIT License