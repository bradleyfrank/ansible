all: dots
dots:
	ansible-playbook play_all_roles.yml --tags dots
moredots:
	ansible-playbook play_all_roles.yml --tags dots,moredots
tmux:
	ansible-playbook play_all_roles.yml --tags tmux --skip-tags become,install
vim:
	ansible-playbook play_all_roles.yml --tags vim --skip-tags become,install
zsh:
	ansible-playbook play_all_roles.yml --tags zsh --skip-tags become,install
shellcheck:
	shellcheck --shell sh install
lint:
	ansible-lint roles --exclude roles/*/files -q
.PHONY: all dots moredots tmux vim zsh shellcheck lint
