# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{functions,path,exports,bash_prompt,aliases,extra,dockerfunc,localfunc}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Bash completions may live in different places, figure out where
BASH_COMPLETION=/usr/local/etc/bash_completion.d
if [ ! -d "$BASH_COMPLETION" ]; then
	BASH_COMPLETION=/etc/bash_completion.d
fi

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f "${BASH_COMPLETION}/git-completion.bash" ]; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for many Bash commands
if exists brew && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
	source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

if is_mac; then

	# Add tab completion for `defaults read|write NSGlobalDomain`
	# You could just use `-g` instead, but I like being explicit
	complete -W "NSGlobalDomain" defaults;

	# Add `killall` tab completion for common apps
	complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;

	# Move next only if `homebrew` is installed
	if exists brew; then
	    # Load rupa's z if installed
	    [ -f $(brew --prefix)/etc/profile.d/z.sh ] && source $(brew --prefix)/etc/profile.d/z.sh
	fi

	# Enable iTerm 2 shell integration
	test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

elif is_wsl; then

	# Make Vagrant use Windows Hyper-V
	export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
	export VAGRANT_DEFAULT_PROVIDER="hyperv"

elif is_linux; then

	# Connect to rootless Docker daemon
	export DOCKER_HOST=unix:///run/user/1000/docker.sock

fi

# Enable GPG for SSH
sshfix

# Add the hey command
if [ -d $HOME/.hey ]; then
    eval "$($HOME/.hey/bin/hey init -)"
fi

# Add the 1p command
if [ -d $HOME/.1password ]; then
    eval "$($HOME/.1password/bin/1p init -)"
fi

# Add the re command
if [ -d $PROJECTS/reMarkable/re ]; then
    eval "$($PROJECTS/reMarkable/re/bin/re init -)"
fi

# Enable direnv
if exists direnv; then
    eval "$(direnv hook bash)"
fi

# Alias hub to git
if exists hub; then
    eval "$(hub alias -s)"
fi