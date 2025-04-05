all: run
run:
	ansible-playbook play_dots.yml --tags dots
moredots:
	ansible-playbook play_dots.yml --tags dots,moredots
.PHONY: all run moredots
