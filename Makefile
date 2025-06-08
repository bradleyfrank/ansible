all: dots
dots:
	ansible-playbook play_dots.yml --tags dots
moredots:
	ansible-playbook play_dots.yml --tags dots,moredots
tmux:
	ansible-playbook play_dots.yml --tags tmux --skip-tags become,install
vim:
	ansible-playbook play_dots.yml --tags vim --skip-tags become,install
zsh:
	ansible-playbook play_dots.yml --tags zsh --skip-tags become,install
shellcheck:
	shellcheck --shell sh install
.PHONY: all dots moredots tmux vim zsh shellcheck
