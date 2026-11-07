# ~/.config/kitty/remote_aliases.sh
# Curated remote shell environment deployed via kitten ssh

# Exit safely if not running in an interactive shell (e.g. scp, rsync, sftp)
case $- in
    *i*) ;;
    *) return 0 2>/dev/null || exit 0 ;;
esac

# ------------------------------------------------------------------------------
# Colorized Output & Sensible Directory Listings
# ------------------------------------------------------------------------------
if ls --color=auto >/dev/null 2>&1; then
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -lah --color=auto'
    alias l='ls -CF --color=auto'
elif ls -G >/dev/null 2>&1; then
    alias ls='ls -G'
    alias ll='ls -lh'
    alias la='ls -lah'
    alias l='ls -CF'
else
    alias ll='ls -lh'
    alias la='ls -lah'
    alias l='ls -CF'
fi

# ------------------------------------------------------------------------------
# Safe File Operations
# ------------------------------------------------------------------------------
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# ------------------------------------------------------------------------------
# Colorized Search
# ------------------------------------------------------------------------------
if grep --color=auto >/dev/null 2>&1; then
    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
fi

# ------------------------------------------------------------------------------
# System & Resource Monitoring
# ------------------------------------------------------------------------------
alias df='df -h'
alias free='free -m 2>/dev/null || free'
alias du1='du -h -d 1 2>/dev/null || du -h --max-depth=1 2>/dev/null || du -h'
alias ports='netstat -tulpn 2>/dev/null || ss -tulpn 2>/dev/null || lsof -i -P -n 2>/dev/null'
alias myip='curl -s ifconfig.me 2>/dev/null || wget -qO- ifconfig.me 2>/dev/null'

# ------------------------------------------------------------------------------
# Git Shortcuts (when available)
# ------------------------------------------------------------------------------
if command -v git >/dev/null 2>&1; then
    alias gs='git status'
    alias gd='git diff'
    alias gl='git log --oneline -n 15'
    alias gb='git branch'
fi

# ------------------------------------------------------------------------------
# Remote Kitten Utilities
# ------------------------------------------------------------------------------
# If kitten is active on the remote host, enable instant image viewing in terminal
if command -v kitten >/dev/null 2>&1; then
    alias icat='kitten icat'
fi

# ------------------------------------------------------------------------------
# Lightweight System Info Summary
# ------------------------------------------------------------------------------
sysinfo() {
    printf "\033[1;36m=== Remote Host: \033[1;32m%s\033[1;36m ===\033[0m\n" "$(hostname 2>/dev/null || uname -n)"
    printf "\033[1mKernel:\033[0m   %s\n" "$(uname -sr 2>/dev/null)"
    printf "\033[1mUptime:\033[0m  %s\n" "$(uptime -p 2>/dev/null || uptime | sed 's/.*up \([^,]*\), .*/\1/')"
    printf "\033[1mMemory:\033[0m  %s\n" "$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}' || echo 'N/A')"
    printf "\033[1mDisk:\033[0m    %s\n" "$(df -h / 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}' || echo 'N/A')"
}

