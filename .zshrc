rxfetch
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^k' history-beginning-search-backward
bindkey '^j' history-beginning-search-forward
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

bindkey '^x' kill-region
bindkey '^l' autosuggest-accept
bindkey '^p' emacs-forward-word

# ZSH_AUTOSUGGEST_STRATEGY=(completion)
# ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(vi-forward-word)

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:mv:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:cp:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 60 8

# Aliases
alias x='exit'
alias ls='ls --color'
alias c='clear'

# Shell integrations
eval "$(fzf --zsh)"
# eval "$(zoxide init --cmd cd zsh)"

#list
alias ls='ls --color=auto'
alias la='ls -a'
alias ll='ls -la'
alias l='ls'
alias l.="ls -A | egrep '^\.'"

#fix obvious typo's
alias cd..='cd ..'
alias pdw="pwd"
alias udpate='sudo pacman -Syyu'
alias upate='sudo pacman -Syyu'

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

#readable output
alias df='df -h'

#pacman unlock
alias unlock="sudo rm /var/lib/pacman/db.lck"

#free
alias free="free -mt"

#use all cores
alias uac="sh ~/.bin/main/000*"

#continue download
alias wget="wget -c"

#userlist
alias userlist="cut -d: -f1 /etc/passwd"

#merge new settings
alias merge="xrdb -merge ~/.Xresources"

# Aliases for software managment
# pacman or pm
alias pacman='sudo pacman --color auto'
alias update='sudo pacman -Syyu'

# yay as aur helper - updates everything
alias pksyua="yay -Syu --noconfirm"
alias upall="yay -Syu --noconfirm"

#ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"

#grub update
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

#add new fonts
alias update-fc='sudo fc-cache -fv'

#copy/paste all content of /etc/skel over to home folder - backup of config created - beware
alias skel='cp -Rf ~/.config ~/.config-backup-$(date +%Y.%m.%d-%H.%M.%S) && cp -rf /etc/skel/* ~'
#backup contents of /etc/skel to hidden backup folder in home/user
alias bupskel='cp -Rf /etc/skel ~/.skel-backup-$(date +%Y.%m.%d-%H.%M.%S)'

#copy bashrc-latest over on bashrc - cb= copy bashrc
#alias cb='sudo cp /etc/skel/.bashrc ~/.bashrc && source ~/.bashrc'
#copy /etc/skel/.zshrc over on ~/.zshrc - cb= copy zshrc
alias cz='sudo cp /etc/skel/.zshrc ~/.zshrc && source ~/.zshrc'

#switch between bash and zsh
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"

#quickly kill conkies
alias kc='killall conky'

#hardware info --short
alias hw="hwinfo --short"


#Recent Installed Packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
alias riplong="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -3000 | nl"

#Cleanup orphaned packages
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

#get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

#nano for important configration files
#know what you do in these files
alias nlightdm="sudo nano /etc/lightdm/lightdm.conf"
alias npacman="sudo nano /etc/pacman.conf"
alias ngrub="sudo nano /etc/default/grub"
alias nmkinitcpio="sudo nano /etc/mkinitcpio.conf"
alias nslim="sudo nano /etc/slim.conf"
alias noblogout="sudo nano /etc/oblogout.conf"
alias nmirrorlist="sudo nano /etc/pacman.d/mirrorlist"
alias nconfgrub="sudo nano /boot/grub/grub.cfg"

#gpg
#verify signature for isos
alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
#receive the key of a developer
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

#shutdown or reboot
alias ssn="sudo shutdown now"
alias sr="sudo reboot"

#maintenance
alias big="expac -H M '%m\t%n' | sort -h | nl"

#systeminfo
alias probe="sudo -E hw-probe -all -upload"

#VPN
#alias vpn="/home/mattia/Documents/Shell-scripts/vpnUnitn.sh"
alias vpn="sudo openconnect --user=mattia.silvestri-1@unitn.it --csd-wrapper /usr/lib/openconnect/hipreport.sh --protocol=gp vpn-mfa.icts.unitn.it/gateway"

#ROBBOT
alias robbot="mount.cifs //192.168.240.42/ROBBOT /mnt/ROBBOT"

#Matlab server
alias matserver="/home/mattia/vim/daeyun/vim-matlab/scripts/vim-matlab-server.py" 

# Ranger
alias fm="ranger"

# Joshuto
alias jm="joshuto"

# Git 
alias s="git status"
alias a="git add"
alias c="git commit"
alias p="git push"
alias pl="git pull"
alias rs="git reset"
alias lg="lazygit"

# Music
alias music='tmux new-session -s $$ "tmux source-file ~/.ncmpcpp/tsession"'
alias ncm="~/.config/ncmpcpp/ncmpcpp-ueberzug/ncmpcpp-ueberzug"

# Text editor
# alias vim="nvim"
alias vi="nvim"

# Tmux
alias a="tmux a"

# Other
alias disc="sudoedit /opt/discord/resources/build_info.json"

# # ex = EXtractor for all kinds of archives
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

#create a file called .zshrc-personal and put all your personal aliases
#in there. They will not be overwritten by skel.

[[ -f ~/.zshrc-personal ]] && . ~/.zshrc-personal

# Startup
# TERM=xterm-kitty
. /home/mattia/.config/ranger/plugins/z/z.sh

export NNN_PLUG='f:finder;o:fzopen;p:preview-tui;d:diffs;t:nmount;v:imgview'
export PATH="$HOME/.emacs.d/bin:$PATH"
export PATH="/usr/bin/site_perl:$PATH"
export PATH="/usr/bin/vendor_perl:$PATH"
export PATH="/usr/bin/core_perl:$PATH"
export PATH="/home/mattia/.local/share/gem/ruby/3.0.0/bin:$PATH"
export PATH="/home/mattia/.cargo/bin:$PATH"
export PATH="/home/mattia/.local/bin:$PATH"
# source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
export QT_QPA_PLATFORM=wayland
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/bin/virtualenvwrapper.sh

export EDITOR=nvim
export VISUAL=nvim

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Joshuto integratrion
function joshuto() {
	ID="$$"
	mkdir -p /tmp/$USER
	OUTPUT_FILE="/tmp/$USER/joshuto-cwd-$ID"
	env joshuto --output-file "$OUTPUT_FILE" $@
	exit_code=$?

	case "$exit_code" in
		# regular exit
		0)
			;;
		# output contains current directory
		101)
			JOSHUTO_CWD=$(cat "$OUTPUT_FILE")
			cd "$JOSHUTO_CWD"
			;;
		# output selected files
		102)
			;;
		*)
			echo "Exit code: $exit_code"
			;;
	esac
}

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/mnt/Data/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/mnt/Data/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/mnt/Data/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/mnt/Data/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
# zmodload zsh/zprof
# zprof

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
