#!/bin/bash

# Shell & Tmux Setup Script
# One-command setup for development environment
# Usage: bash setup.sh

set -e  # Exit on any error

echo "🚀 Starting Shell & Tmux Setup..."

# Check if running on supported system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    INSTALL_CMD="sudo apt update && sudo apt install -y"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    INSTALL_CMD="brew install"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

# 1. Install zsh and tmux
echo "📦 Installing zsh and tmux..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt update
    sudo apt install -y zsh tmux git curl
else
    brew install zsh tmux git curl
fi

# 2. Install zsh-autosuggestions
echo "🔧 Installing zsh-autosuggestions..."
rm -rf ~/.zsh/zsh-autosuggestions 2>/dev/null || true
mkdir -p ~/.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# 3. Backup existing configs
echo "💾 Backing up existing configurations..."
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
[ -f ~/.tmux.conf ] && cp ~/.tmux.conf ~/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)

# 4. Create .zshrc
echo "⚙️  Creating .zshrc configuration..."
cat > ~/.zshrc << 'EOF'
# Clean Zsh configuration for development
# History settings
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Basic options
setopt AUTO_CD
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt NO_BEEP

# Simple prompt with git info
autoload -Uz vcs_info
precmd_functions+=( vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:*' enable git
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{red}${vcs_info_msg_0_}%f$ '

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'

# Load environment variables (if they exist)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# NVM (if installed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Function to start development environment (just panes, no commands)
start_dev_env() {
    tmux new-session -d -s dev
    tmux split-window -t dev -v
    tmux split-window -t dev -h
    tmux select-pane -t dev:0.0
    tmux attach-session -t dev
}

# Load zsh-autosuggestions plugin
if [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    # Autosuggestion settings
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi
EOF

# 5. Create .tmux.conf
echo "⚙️  Creating .tmux.conf configuration..."
cat > ~/.tmux.conf << 'EOF'
# Tmux Configuration for Development

# Basic settings
set -g default-terminal "screen-256color"
set -g mouse on
set -g history-limit 10000
set -g base-index 1
setw -g pane-base-index 1

# Key bindings
# Change prefix to Ctrl-a (easier than Ctrl-b)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config file
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Mac-friendly pane navigation (Option + arrow keys)
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Switch windows (Shift + arrow keys)
bind -n S-Left previous-window
bind -n S-Right next-window

# Alternative: use prefix + hjkl for vim-style navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes with prefix + HJKL
bind H resize-pane -L 5
bind J resize-pane -D 5
bind K resize-pane -U 5
bind L resize-pane -R 5

# Visual styling
set -g status-bg black
set -g status-fg white
set -g status-interval 60
set -g status-left-length 30
set -g status-left '#[fg=green]#S #[fg=white]| '
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M#[default]'

# Highlight active window
setw -g window-status-current-style 'fg=white bg=red bold'

# Pane border colors
set -g pane-border-style 'fg=colour238'
set -g pane-active-border-style 'fg=colour51'

# Message colors
set -g message-style 'fg=white bg=black'

# Don't rename windows automatically
set-option -g allow-rename off

# Enable vi mode for copy mode
setw -g mode-keys vi
bind-key -T copy-mode-vi 'v' send -X begin-selection
bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel

# Quick session layouts (just panes, no commands)
# Create development session with 3 panes
bind-key M-d new-session -d -s dev \; \
    split-window -v \; \
    split-window -h \; \
    select-pane -t 0
EOF

# 6. Set zsh as default shell
echo "🔧 Setting zsh as default shell..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo chsh -s $(which zsh) $USER || {
        echo "⚠️  Could not set zsh as default shell automatically."
        echo "   Run this command after the script completes:"
        echo "   sudo chsh -s \$(which zsh) $USER"
        echo "   Then log out and log back in."
    }
else
    # macOS
    if ! grep -q "$(which zsh)" /etc/shells; then
        echo "$(which zsh)" | sudo tee -a /etc/shells
    fi
    chsh -s $(which zsh) || {
        echo "⚠️  Could not set zsh as default shell automatically."
        echo "   Run: chsh -s \$(which zsh)"
        echo "   Then restart your terminal."
    }
fi

echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "📋 What was installed:"
echo "   • Zsh with auto-suggestions"
echo "   • Tmux with Mac-friendly navigation" 
echo "   • Clean development configuration"
echo ""
echo "🎯 Next steps:"
echo "   1. Restart your terminal or log out/in for zsh to be default"
echo "   2. Try typing commands to see auto-suggestions"
echo "   3. Use 'start_dev_env' to launch tmux with 3 panes"
echo ""
echo "📖 Navigation:"
echo "   • Zsh: Type commands, see gray suggestions, press Tab/→ to accept"
echo "   • Tmux: Option+arrows (panes), Shift+arrows (windows), Ctrl-a+| (split)"
echo ""
echo "📄 Documentation: Check shell-tmux-setup.md for full details"
echo ""

# Create marker file to indicate setup was run
touch ~/.shell-tmux-setup-complete
echo "Setup completed at $(date)" > ~/.shell-tmux-setup-complete