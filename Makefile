SHELL = /bin/bash

ANSIBLE = ansible
ANSIBLE_PLAYBOOK = ansible-playbook

VENV_DIR=$(shell poetry env info --path)

ANSIBLE_LINT_TARGETS = playbooks # TODO: add 'roles' dir when it exists

export PATH := $(VENV_DIR)/bin:$(PATH)

.PHONY: all ping \
	setup create-venv install-deps install-galaxy-deps \
	lint test-role

all:

ping:
	$(ANSIBLE) -m ping localhost

setup: create-venv install-deps install-galaxy-deps

create-venv: $(VENV_DIR)

$(VENV_DIR):
	poetry install

# Quick reminder: '|' is for order-only prerequisites
# https://www.gnu.org/software/make/manual/make.html#Prerequisite-Types

install-galaxy-deps: | $(VENV_DIR)/bin/ansible-galaxy
	$(VENV_DIR)/bin/ansible-galaxy install -r galaxy-requirements.yml

$(VENV_DIR)/bin/ansible-galaxy: | install-deps

# Work around ansible-lint issue - roles_path from ansible.cfg is not used
# https://github.com/ansible-community/ansible-lint/issues/1336
lint: export ANSIBLE_ROLES_PATH = $(strip $(shell grep roles_path ansible.cfg | cut -d= -f2))

lint:
	ansible-lint $(ANSIBLE_LINT_TARGETS)
