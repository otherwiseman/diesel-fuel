# sh will not work for most of this
[ -z "$BASH" ] && exit

[ `which transset` ] && transset -a .97 &> /dev/null

shopt -s cdable_vars cmdhist histappend cdspell checkwinsize

OS=`uname`

setup_scm() {
	[[ $PWD == *.git* ]] && return
	# prompt scm
	SCM=""
	VCS=""
	local status branch commits changed root url
	git rev-parse --show-toplevel &> /dev/null
	if [ $? -eq 0 ]; then
		status="`git status -sb`"
		read branch commits <<<`echo "$status" | head -n1 | tr '.[]#' ' ' | awk '{print $1" "$5}'`
		[ -z "$commits" ] && commits=0
		changed="`echo "$status" | grep -v "^##" | wc -l`"
		VCS="git"
	else
		SCM=""
		VCS=""
	fi
	[ -n "$branch" ] && SCM="$VCS:$branch (${changed//[[:space:]]}|$commits) "
	SCM_PROMPT="$SCM$PWD"
}

setup_scm_prompt() {
	echo -n $SCM_PROMPT
}

export PROMPT_COMMAND="history -a; setup_scm"
export PS1='\[\033]2;\h:\w\a\]$(setup_scm_prompt)\n» '


# OSX Overrides
if [[ "$OS" = "Darwin" || "$OS" = "FreeBSD" ]]; then
	LS_COL_ARG="-G"
	export CLICOLOR=1
	export LSCOLORS=dxfxcxdxbxegedabagacad
	[ "$OS" = "Darwin" ] && alias gvim=mvim
elif [ "$OS" = "Linux" ]; then
	LS_COL_ARG="--color=auto"
fi

export PAGER="less"
export VISUAL="vim"
export EDITOR="vim"

# Tell less not to beep and also display colours
export LESS="-QR"

#parses .dircolors and makes env var for GNU ls
eval `dircolors`
alias ls='ls -hF --color=auto'
alias v='vi'
alias pycharm="open /Applications/Pycharm.app/Contents/MacOS/pycharm"
alias act='source _install/bin/activate'
alias dct='deactivate'
alias grafana_data="/usr/local/var/lib/grafana"

# bashrc processing
alias rc=". ~/.bashrc"

# generic aliases
alias c="clear"
alias h='history | grep "$@"'
alias ls="ls -Fh $LS_COL_ARG"
alias la="ls -AFh $LS_COL_ARG"
alias ll="ls -AlFh $LS_COL_ARG"


SEQ="seq"
[ "$OS" = "Darwin" ] && SEQ="jot -"
# directory navigation
up() {
  if [ $# == 0 ]; then
	  cd ..
	  return
  fi
  num=`echo $1 | grep -v "[[:alpha:]]"`
  if [ "$num" == "" ]; then
	  echo "Usage: up [# of folders to go up]"
	  return 1
  fi
  local args=""
  for i in `$SEQ 1 $1`
  do
	if [ $i -gt 1 ]
	then
	  args="$args/"
	fi
	args="$args.."
  done
  echo cd $args
  cd $args
}

# get ip addrs of interfaces
getip() {
	[ $# == 0 ] && echo "Usage: getip <iface>" && return 1
	echo `ip -o -4 addr show $1`
}


bind "set completion-ignore-case on"
bind "set completion-map-case on"
bind "set show-all-if-ambiguous on"
