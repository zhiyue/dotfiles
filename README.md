# My Dotfiles

使用 [chezmoi](https://www.chezmoi.io/) 管理的个人配置文件。这个仓库包含了我在不同操作系统（Windows、macOS、Linux）上使用的配置文件，通过 chezmoi 的模板系统实现了跨平台的配置管理。

## 仓库结构

```
.
├── .chezmoiexternal.toml  # 外部依赖配置
├── .chezmoiignore         # 忽略文件配置
├── .chezmoiroot           # 指定源目录为 home
├── README.md              # 本文档
└── home/                  # 主要配置文件目录
    ├── .chezmoi.toml.tmpl            # chezmoi 配置模板
    ├── .chezmoiscripts/              # 自动化脚本目录
    │   └── windows/                  # Windows 特定脚本
    │       └── run_once_install-packages.ps1  # 安装软件包脚本
    ├── .chezmoitemplates/            # 模板文件目录
    │   └── dot_gitconfig.windows     # Windows 的 Git 配置模板
    ├── Documents/                    # 文档目录
    │   └── WindowsPowerShell/        # PowerShell 配置
    │       └── Microsoft.PowerShell_profile.ps1  # PowerShell 配置文件
    ├── dot_config/                   # .config 目录（Linux/macOS）
    ├── dot_gitignore_global          # 全局 Git 忽略文件
    └── symlink_dot_gitconfig.tmpl    # Git 配置符号链接模板
```

## 安装

### Linux/macOS 用户

```bash
# 安装 chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin

# 初始化 chezmoi 仓库
chezmoi init zhiyue/dotfiles

# 编辑 chezmoi 配置（可选，会打开 .chezmoi.toml.tmpl）
chezmoi edit-config

# 应用配置
chezmoi apply
```

### Windows 用户

```powershell
# 安装 chezmoi
(irm -useb get.chezmoi.io/ps1) | powershell -c -

# 初始化 chezmoi 仓库
chezmoi init zhiyue/dotfiles

# 编辑 chezmoi 配置（可选，会打开 .chezmoi.toml.tmpl）
chezmoi edit-config

# 应用配置
chezmoi apply
```

## 日常使用

### 更新配置

从远程仓库拉取最新更改并应用：

```bash
chezmoi update
```

### 编辑配置

```bash
# 编辑文件
chezmoi edit ~/.gitconfig

# 应用更改
chezmoi apply
```

### 添加新文件

```bash
# 添加现有文件
chezmoi add ~/.bashrc

# 编辑添加的文件
chezmoi edit ~/.bashrc

# 应用更改
chezmoi apply
```

### 查看将要进行的更改

在应用更改前查看差异：

```bash
chezmoi diff
```

## 模板系统

本仓库使用 chezmoi 的模板系统来处理不同操作系统的配置差异：

- `.tmpl` 文件：使用 Go 模板语法，根据操作系统等条件生成不同的配置
- `.chezmoitemplates/` 目录：存放可重用的模板片段
- 操作系统检测：使用 `{{ if eq .chezmoi.os "windows" }}` 等条件语句

例如，Git 配置通过 `symlink_dot_gitconfig.tmpl` 根据不同操作系统链接到相应的配置文件。

## 自动化脚本

`.chezmoiscripts/` 目录包含在配置应用时自动执行的脚本：

- Windows 脚本：安装常用软件包（通过 Scoop）
- 脚本命名规则：`run_once_` 前缀表示脚本只会执行一次

## 故障排除

### 模板变量问题

如果在 `.chezmoiscripts` 目录下的 `.tmpl` 文件中模板变量不能正常工作，可能需要使用绝对路径或硬编码值。

### 配置冲突

如果本地修改与远程更新冲突：

```bash
# 查看差异
chezmoi diff

# 合并更改（保留本地修改）
chezmoi merge ~/.bashrc
```

## 贡献

欢迎提交 Pull Request 或 Issue 来改进这个配置仓库。在提交前，请确保：

1. 测试过你的更改在目标操作系统上正常工作
2. 更新相关文档
3. 遵循现有的代码风格和组织结构
