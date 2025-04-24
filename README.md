# My Dotfiles

使用 [chezmoi](https://www.chezmoi.io/) 管理的个人配置文件。这个仓库包含了我在不同操作系统（Windows、macOS、Linux、WSL）上使用的配置文件，通过 chezmoi 的模板系统实现了跨平台的配置管理。

## 仓库结构

```
.
├── .chezmoiexternal.toml  # 外部依赖配置
├── .chezmoiignore         # 忽略文件配置
├── .chezmoiroot           # 指定源目录为 home
├── README.md              # 本文档
├── install.sh             # 容器环境安装脚本
└── home/                  # 主要配置文件目录
    ├── .chezmoi.toml.tmpl            # chezmoi 配置模板
    ├── .chezmoiscripts/              # 自动化脚本目录
    │   ├── linux/                    # Linux 特定脚本
    │   │   ├── run_once_before_000_install_1password_cli.sh.tmpl  # 1Password CLI 安装
    │   │   ├── run_once_before_fetch_age_key.sh.tmpl             # 获取 age 密钥
    │   │   ├── run_once_install-atuin.sh.tmpl                    # Atuin 安装
    │   │   └── run_once_install-starship.sh.tmpl                 # Starship 安装
    │   ├── windows/                  # Windows 特定脚本
    │   │   ├── run_once_before_fetch_age_key.ps1.tmpl            # 获取 age 密钥
    │   │   └── run_once_install-packages.ps1                     # 安装软件包脚本
    │   └── wsl/                      # WSL 特定脚本
    │       ├── run_once_000_setup_sudo_proxy.sh.tmpl             # 设置 sudo 代理
    │       ├── run_once_001_change_to_cn_mirror.sh.tmpl          # 切换到中国镜像源
    │       ├── run_once_install-zsh.sh.tmpl                      # 安装 Zsh
    │       └── run_once_setup-1password-ssh-agent.sh.tmpl        # 设置 1Password SSH 代理
    ├── .chezmoitemplates/            # 模板文件目录
    │   ├── Microsoft.PowerShell_profile.ps1  # PowerShell 配置模板
    │   ├── dot_gitconfig.linux       # Linux 的 Git 配置模板
    │   ├── dot_gitconfig.windows     # Windows 的 Git 配置模板
    │   ├── dot_gitconfig.wsl         # WSL 的 Git 配置模板
    │   ├── dot_ssh_config.linux      # Linux 的 SSH 配置模板
    │   └── dot_ssh_config.wsl        # WSL 的 SSH 配置模板
    ├── AppData/                      # Windows 应用数据目录
    ├── Documents/                    # 文档目录
    │   └── WindowsPowerShell/        # PowerShell 配置
    │       └── Microsoft.PowerShell_profile.ps1  # PowerShell 配置文件
    ├── dot_config/                   # .config 目录（Linux/macOS/WSL）
    │   └── starship.toml             # Starship 终端提示符配置
    ├── dot_local/                    # .local 目录（Linux/WSL）
    ├── dot_ssh/                      # SSH 配置目录
    ├── dot_bashrc                    # Bash 配置文件
    ├── dot_gitignore_global          # 全局 Git 忽略文件
    ├── dot_zshrc                     # Zsh 配置文件
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

### WSL 用户

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

WSL 环境会自动安装以下工具：
- Zsh 和 Oh My Zsh
- Starship 终端提示符
- Atuin 命令历史搜索工具
- 1Password CLI 和 SSH 代理集成
- 中国镜像源配置（可选）

## 日常使用

### 确保 chezmoi 在 PATH 中

本仓库已在 `.bashrc` 和 `.zshrc` 中自动添加了以下配置，确保 chezmoi 可以在 Linux/WSL 环境中被找到：

```bash
# Add chezmoi to PATH if it exists
if [ -f "$HOME/.local/bin/chezmoi" ] && ! command -v chezmoi &> /dev/null; then
    export PATH="$HOME/.local/bin:$PATH"
fi
```

对于 PowerShell 用户，您可以通过编辑 PowerShell 配置文件来添加 chezmoi 到 PATH：

```powershell
# 在 PowerShell 配置文件中添加 chezmoi 到 PATH
$env:Path += ";$env:USERPROFILE\.local\bin"
```

您可以通过取消注释 `.chezmoitemplates/Microsoft.PowerShell_profile.ps1` 中的相关行来启用此功能。

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
- `.chezmoi.toml.tmpl`：定义 chezmoi 的配置，如编辑器设置等

### 环境检测变量

本仓库定义了以下环境检测变量，用于在模板中区分不同的运行环境：

- `.is_windows`：是否运行在 Windows 系统上
- `.is_container`：是否运行在容器（Docker/Podman/devcontainer 等）中
- `.is_wsl`：是否运行在 WSL 环境中（无论実际环境是容器还是実际的 WSL）
- `.is_wsl_host`：是否运行在 WSL 実际环境中（非容器）

这些变量在 `.chezmoi.toml.tmpl` 中定义，并在模板中使用，例如：

```
{{ if .is_windows }}
# Windows 特定配置
{{ else if .is_wsl_host }}
# WSL 特定配置
{{ else if .is_container }}
# 容器特定配置
{{ else }}
# 其他 Linux 特定配置
{{ end }}
```

这些变量比直接使用 chezmoi 内置变量更加清晰和简洁，例如使用 `.is_wsl` 而不是：

```
{{ if and (eq .chezmoi.os "linux") (contains "microsoft" .chezmoi.kernel.osrelease) }}
```

例如，Git 配置通过 `symlink_dot_gitconfig.tmpl` 根据不同操作系统链接到相应的配置文件，包括 Windows、Linux 和 WSL 特定配置。

**注意**：由于使用了 `.chezmoi.toml.tmpl`，在初始化时需要先运行 `chezmoi init` 然后再运行 `chezmoi apply`，而不是直接使用 `chezmoi init --apply`。

## 自动化脚本

`.chezmoiscripts/` 目录包含在配置应用时自动执行的脚本：

- Windows 脚本：安装常用软件包（通过 Scoop）和获取 age 密钥
- Linux 脚本：安装 Starship、Atuin、1Password CLI 和获取 age 密钥
- WSL 脚本：设置 1Password SSH 代理、安装 Zsh、切换到中国镜像源
- 脚本命名规则：
  - `run_once_` 前缀表示脚本只会执行一次
  - `run_once_before_` 前缀表示脚本在应用配置前执行
  - 数字前缀（如 `000_`）用于控制执行顺序

## 特殊功能

### 加密支持

本仓库使用 [age](https://github.com/FiloSottile/age) 加密敏感文件：

- `.chezmoi.toml.tmpl` 中配置了 age 加密
- 敏感文件使用 `.age` 后缀，会自动加密/解密
- 密钥通过 `run_once_before_fetch_age_key` 脚本获取

### 1Password 集成

本仓库支持与 1Password 密码管理器集成：

- 在 Linux/WSL 环境中安装 1Password CLI
- 在 WSL 中设置 1Password SSH 代理，实现与 Windows 1Password 应用的集成
- 配置 Git 使用 1Password SSH 密钥进行签名

**注意**：在 Linux 和 WSL 环境中使用前，需要设置 1Password 服务账号令牌：

```bash
# 设置 1Password 服务账号令牌环境变量
export OP_SERVICE_ACCOUNT_TOKEN="你的服务账号令牌"

# 验证 1Password CLI 是否可用
op --version
```

服务账号令牌可以在 1Password 账户设置中创建，用于自动化脚本访问 1Password 数据。

### Atuin 历史搜索

[Atuin](https://github.com/atuinsh/atuin) 提供增强的 shell 历史搜索和同步功能：

- 自动安装并配置 Atuin
- 在 `.bashrc` 和 `.zshrc` 中集成 Atuin
- 在 Windows 环境中忽略 Atuin 私钥文件

### Bash Line Editor (ble.sh)

[ble.sh](https://github.com/akinomyoga/ble.sh) 是一个增强 Bash 命令行编辑器：

- 自动安装到 `~/.local/share/blesh`
- 在 `.bashrc` 中集成
- 提供语法高亮、智能补全和其他增强功能

## 故障排除

### 模板变量问题

如果在 `.chezmoiscripts` 目录下的 `.tmpl` 文件中模板变量不能正常工作，可能需要使用绝对路径或硬编码值。

### WSL 网络问题

在 WSL 环境中，如果遇到网络连接问题：

- 检查 `/etc/resolv.conf` 配置
- 尝试使用 `run_once_000_setup_sudo_proxy.sh.tmpl` 脚本设置代理
- 对于中国用户，可以使用 `run_once_001_change_to_cn_mirror.sh.tmpl` 切换到国内镜像源

### 配置冲突

如果本地修改与远程更新冲突：

```bash
# 查看差异
chezmoi diff

# 合并更改（保留本地修改）
chezmoi merge ~/.bashrc
```

## 跨平台支持

### Windows 特定功能

- 通过 Scoop 安装常用软件包
- PowerShell 配置文件和别名
- Windows Terminal 配置
- PowerShell DirColors 模块（提供类 Unix 的文件颜色显示）
- Starship 终端提示符集成

### Linux 特定功能

- Bash 和 Zsh 配置
- Starship 终端提示符
- 常用命令行工具配置

### WSL 特定功能

- 与 Windows 主机的集成（1Password、SSH 代理等）
- 中国镜像源配置
- WSL 特定的 Git 和 SSH 配置

## 在 VSCode 开发容器中使用

本仓库已配置为可以在 VSCode 开发容器（Dev Containers）中使用。这样，当您在任何项目的开发容器中工作时，都能自动应用您的个人配置。

### 设置步骤

1. 确保您已安装 [VS Code](https://code.visualstudio.com/) 和 [Dev Containers 扩展](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

2. 在 VS Code 中，打开设置（`Ctrl+,` 或 `Cmd+,`），搜索 `dotfiles`

3. 在 `Dev > Containers: Dotfiles` 设置中添加以下配置：
   - **Repository**: `zhiyue/dotfiles`
   - **Target Path**: `~/dotfiles`
   - **Install Command**: `./install.sh`

   或者，直接在 `settings.json` 中添加：
   ```json
   "dev.containers.dotfiles.repository": "zhiyue/dotfiles",
   "dev.containers.dotfiles.targetPath": "~/dotfiles",
   "dev.containers.dotfiles.installCommand": "./install.sh"
   ```

4. 现在，每当您打开一个开发容器时，VS Code 将自动克隆您的 dotfiles 仓库并运行安装脚本，从而应用您的个人配置。

### 工作原理

- 当开发容器启动时，VS Code 会克隆您的 dotfiles 仓库到容器中
- 安装脚本 (`install.sh`) 会安装 chezmoi 并应用您的配置
- 脚本会检测容器环境并相应地调整配置
- 您的 shell、编辑器和其他工具配置将在容器中可用

### 注意事项

- 容器环境中会使用 vim 作为默认编辑器（而不是 VS Code）
- 某些特定于操作系统的配置会根据容器环境自动调整
- 如果您在容器中遇到问题，可以手动运行 `chezmoi apply -v` 查看详细输出

## 贡献

欢迎提交 Pull Request 或 Issue 来改进这个配置仓库。在提交前，请确保：

1. 测试过你的更改在目标操作系统上正常工作
2. 更新相关文档
3. 遵循现有的代码风格和组织结构
