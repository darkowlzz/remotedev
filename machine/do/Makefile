.DEFAULT_GOAL:=help

.PHONY: help up clean ssh

# Setup dir contains all the manifests and scripts to setup test infra.
SETUP_DIR ?= envsetup

STACK_NAME ?= remotedev

CONTAINER_IMAGE ?= darkowlzz/remotedev:v0.0.1


help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

up: ## Provision the machine.
	bash $(SETUP_DIR)/run-in-docker.sh $(CONTAINER_IMAGE) $(SETUP_DIR)/up.sh $(STACK_NAME)

clean: ## Delete the machine.
	bash $(SETUP_DIR)/run-in-docker.sh $(CONTAINER_IMAGE) $(SETUP_DIR)/destroy.sh $(STACK_NAME)

status: ## Show the machine status.
	bash $(SETUP_DIR)/run-in-docker.sh $(CONTAINER_IMAGE) $(SETUP_DIR)/preview.sh $(STACK_NAME)

ssh: ## SSH into the machine.
	bash $(SETUP_DIR)/run-in-docker.sh $(CONTAINER_IMAGE) $(SETUP_DIR)/ssh.sh $(STACK_NAME)

deps: ## Install all the dependencies and configurations before provisioning a machine.
	bash $(SETUP_DIR)/deps.sh

distclean: clean ## Cleanup everything, machine, config and generated files.
	bash $(SETUP_DIR)/run-in-docker.sh $(CONTAINER_IMAGE) $(SETUP_DIR)/delete-stack.sh $(STACK_NAME)
	bash $(SETUP_DIR)/delete-ssh-key.sh
	rm -rf .ssh/ .pulumi/ .sync/ config.yaml

sync: ## Syncs the specified directory in config to the remote machine.
	bash $(SETUP_DIR)/sync-local.sh
	bash $(SETUP_DIR)/run-in-docker.sh $(CONTAINER_IMAGE) $(SETUP_DIR)/sync-remote.sh
