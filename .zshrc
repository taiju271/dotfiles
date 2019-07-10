path=($HOME/.local/bin(N-/) $HOME/bin(N-/) /usr/local/sbin(N-/) /usr/local/bin(N-/) /usr/sbin(N-/) /usr/bin(N-/) /sbin(N-/) /bin(N-/))
export SHELL=`which zsh`

autoload -U colors && colors
autoload -U compinit && compinit

######################################################################
# tmux
######################################################################
function is_exists() { type "$1" >/dev/null 2>&1; return $? }
function is_screen_running() { ! test -z "$STY" }
function is_tmux_runnning() { ! test -z "$TMUX" }
function is_screen_or_tmux_running() { is_screen_running || is_tmux_runnning }
function shell_has_started_interactively() { ! test -z "$PS1" }

function tmux_automatically_attach_session()
{
	if is_screen_or_tmux_running; then
		! is_exists 'tmux' && return 1

		if is_tmux_runnning; then
			echo "${fg_bold[red]} _____ __  __ _   _ __  __ ${reset_color}"
			echo "${fg_bold[red]}|_   _|  \/  | | | |\ \/ / ${reset_color}"
			echo "${fg_bold[red]}  | | | |\/| | | | | \  /  ${reset_color}"
			echo "${fg_bold[red]}  | | | |  | | |_| | /  \  ${reset_color}"
			echo "${fg_bold[red]}  |_| |_|  |_|\___/ /_/\_\ ${reset_color}"
		elif is_screen_running; then
			echo "This is on screen."
		fi
	else
		if shell_has_started_interactively; then
			if ! is_exists 'tmux'; then
				echo 'Error: tmux command not found' 2>&1
				return 1
			fi

			# アタッチされていないセッションがある場合だけ
			#if tmux has-session >/dev/null 2>&1 && tmux list-sessions | grep -qE '.*]$'; then
			# セッションが既にある場合は常に
			if tmux has-session >/dev/null 2>&1; then
				# detached session exists
				tmux list-sessions
				echo -n "Tmux: attach? (y/N/num) "
				read
				if [[ "$REPLY" =~ ^[Yy]$ ]] || [[ "$REPLY" == '' ]]; then
					exec tmux attach-session
				elif [[ "$REPLY" =~ ^[0-9]+$ ]]; then
					exec tmux attach -t "$REPLY"
				fi
			fi
			exec tmux new-session && echo "tmux created new session"
		fi
	fi
}
tmux_automatically_attach_session

######################################################################
# anyenv
######################################################################
if [ ! -f ~/.anyenv/bin/anyenv ]; then
	rm -rf ~/.anyenv
	git clone https://github.com/riywo/anyenv.git ~/.anyenv
fi
if [ ! -d ~/.anyenv/plugins/anyenv-update ]; then
	rm -rf ~/.anyenv/plugins/anyenv-update
	git clone https://github.com/znz/anyenv-update.git ~/.anyenv/plugins/anyenv-update
fi

path=($HOME/.anyenv/bin(N-/) $path)

if (( $+commands[anyenv] )); then
	eval "$(anyenv init -)"
fi

######################################################################
# zplug
######################################################################
if [ ! -f ~/.zplug/init.zsh ]; then
	rm -rf ~/.zplug
	git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

zplug "zplug/zplug"

# プラグイン
zplug "$HOME/.zsh", from:local
zplug "esc/conda-zsh-completion"
zplug "lib/completion", from:oh-my-zsh
zplug "mollifier/cd-gitroot"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# コマンド
zplug "monochromegane/the_platinum_searcher", as:command, from:gh-r, rename-to:pt
zplug "motemen/ghq",                          as:command, from:gh-r, rename-to:ghq
zplug "peco/peco",                            as:command, from:gh-r, rename-to:peco
zplug "stedolan/jq",                          as:command, from:gh-r, rename-to:jq
zplug "direnv/direnv",                        as:command, rename-to:direnv, use:direnv, hook-build:make

# テーマ
zplug "mafredri/zsh-async"
zplug "sindresorhus/pure", as:theme, use:pure.zsh

# 未インストール項目をインストールする
if ! zplug check --verbose; then
	printf "Install? [y/N]: "
	if read -q; then
		echo; zplug install
	fi
fi

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load --verbose

######################################################################
# environment
######################################################################
path=($HOME/.cargo/bin(N-/) $path)
path=($HOME/.composer/vendor/bin(N-/) $path)
path=($HOME/Go/bin(N-/) $path)

export GOPATH=$HOME/.go
export EDITOR=vim

bindkey -e

######################################################################
# alias
######################################################################
alias zreload="exec zsh -l"
alias cdg='cd-ghq'
alias cdu='cd-gitroot'
alias ls="ls -F --color=always"

if ! which tac >/dev/null 2>&1; then
	alias tac="tail -r"
fi

if which nvim >/dev/null; then
	alias vi="nvim"
	alias vim="nvim"
else
	which nvim
fi

######################################################################
# options
######################################################################
setopt auto_cd
setopt auto_pushd
setopt correct
setopt list_packed
setopt nolistbeep
setopt IGNOREEOF
setopt auto_menu
setopt complete_aliases

######################################################################
# history
######################################################################
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000
setopt hist_ignore_dups
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_no_store
setopt hist_expand
setopt inc_append_history

######################################################################
# other
######################################################################
if (( $+commands[direnv] )); then eval "$(direnv hook zsh)"; fi
if (( $+commands[thefuck] )); then eval "$(thefuck --alias)"; fi

######################################################################
# key bind
######################################################################
bindkey '^r' peco-select-history
bindkey '.' multi-dot

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/usr10048126/.local/google-cloud-sdk/path.zsh.inc' ]; then . '/home/usr10048126/.local/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/usr10048126/.local/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/usr10048126/.local/google-cloud-sdk/completion.zsh.inc'; fi

# >>> conda initialize >>>
. "$HOME/.miniconda3/etc/profile.d/conda.sh"
# <<< conda initialize <<<
