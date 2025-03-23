#!/bin/bash

# 导航
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# ls 增强
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    alias ls='ls -G'
    alias ll='ls -alFG'
else
    # Linux/WSL
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
fi
alias la='ls -A'
alias l='ls -CF'

# Git 快捷方式
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gco='git checkout'

# 系统
alias c='clear'
alias h='history'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'

# 安全性
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# 目录快捷方式
alias dot='cd ~/.dotfiles'
alias dev='cd ~/Development'
alias doc='cd ~/Documents'
alias dl='cd ~/Downloads'

# Docker 快捷方式
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# 系统监控
alias df='df -h'
alias du='du -h'
alias free='free -m'
alias top='htop'

# 网络
alias ip='ipconfig'
alias ports='netstat -tuln'
alias myip='curl http://ipecho.net/plain; echo'

# 开发工具
alias code='code-insiders'
alias py='python'
alias pip='pip3'
alias npm='npm'
alias nr='npm run'
alias ni='npm install'
alias nid='npm install --save-dev'

# Python 虚拟环境
alias venv='python -m venv .venv'
alias activate='source .venv/bin/activate'
alias deactivate='deactivate'

# 实用工具
alias weather='curl wttr.in'
alias serve='python -m http.server'
alias zshconfig='code ~/.zshrc'
alias bashconfig='code ~/.bashrc'

# 清理
alias cleanup='rm -rf ~/.cache/* && rm -rf ~/.Trash/*'
alias npm-cleanup='rm -rf node_modules package-lock.json'