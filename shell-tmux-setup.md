# Shell & Tmux Setup Guide

This document explains the complete shell and tmux setup configuration for development environments.

## Overview

This setup provides:
- **Zsh** as the default shell with auto-suggestions
- **Tmux** with Mac-friendly navigation
- Clean development environment without blockchain-specific bloat
- One-command setup for new VMs/machines

## What Was Done

### 1. Zsh Configuration
- Set zsh as default shell
- Configured history settings (50,000 commands)
- Added git branch info to prompt
- Installed zsh-autosuggestions for real-time command suggestions
- Added useful aliases

### 2. Tmux Configuration  
- Changed prefix from `Ctrl-b` to `Ctrl-a`
- Mac-friendly navigation with Option + arrows
- Vim-style pane navigation
- Clean visual styling
- Development session shortcuts

### 3. Auto-suggestions
- Real-time command suggestions as you type
- Suggestions from both history and completions
- Accept with Tab or right arrow

## Files Created/Modified

### ~/.zshrc
Main zsh configuration with:
- History settings
- Git prompt
- Auto-suggestions plugin
- Development aliases
- Environment variables

### ~/.tmux.conf
Tmux configuration with:
- Mac navigation bindings
- Visual styling
- Session management shortcuts

## Navigation Guide

### Zsh Auto-suggestions
- Type any command and see suggestions in gray
- Press `Tab` or `→` to accept suggestion
- Based on your command history and available completions

### Tmux Navigation (Mac)
**No prefix needed:**
- `Option + ←↑↓→` - Move between panes
- `Shift + ←→` - Switch between windows

**With prefix (Ctrl-a):**
- `Ctrl-a + |` - Split vertically
- `Ctrl-a + -` - Split horizontally  
- `Ctrl-a + h/j/k/l` - Vim-style pane navigation
- `Ctrl-a + H/J/K/L` - Resize panes
- `Ctrl-a + x` - Close pane
- `Ctrl-a + d` - Detach session
- `Ctrl-a + Option-d` - Create dev session with 3 panes

### Useful Functions
- `start_dev_env` - Launch tmux session with 3 empty panes

## One-Command Setup

To set up this configuration on a new machine, run:

```bash
curl -fsSL https://raw.githubusercontent.com/your-repo/setup.sh | bash
```

Or manually run the setup script (see next section).

## Manual Setup Commands

```bash
# Install zsh and tmux
sudo apt update && sudo apt install -y zsh tmux

# Set zsh as default shell
sudo chsh -s $(which zsh) $USER

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# Copy configuration files (see setup.sh script)
```

## Configuration Files Content

The actual configuration files are backed up in this directory:
- `zshrc-backup` - Complete .zshrc content
- `tmux-conf-backup` - Complete .tmux.conf content
- `setup.sh` - Automated setup script

## Usage Tips

1. **First Login**: After setup, log out and log back in for zsh to be default
2. **Auto-suggestions**: Start typing and watch suggestions appear in gray
3. **Tmux Sessions**: Use `tmux ls` to see all sessions, `tmux attach -t name` to reconnect
4. **Terminal Settings**: For Mac, ensure Option key sends escape sequences in terminal preferences

## Troubleshooting

**Auto-suggestions not working?**
- Reload shell: `source ~/.zshrc`
- Check plugin installed: `ls ~/.zsh/zsh-autosuggestions/`

**Tmux navigation not working on Mac?**
- Check terminal preferences: Option key should send escape sequences
- For iTerm2: Preferences → Profiles → Keys → Left/Right Option key = "Esc+"

**Default shell not changing?**
- Log out and log back in
- Check with: `echo $SHELL`

## Customization

To customize further:
- Edit `~/.zshrc` for shell settings
- Edit `~/.tmux.conf` for tmux settings  
- Reload with `source ~/.zshrc` or `Ctrl-a + r` (tmux)

---

*Generated for VM/machine portability. Copy this entire directory to new machines and run setup.sh*