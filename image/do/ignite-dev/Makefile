.DEFAULT_GOAL:=help

.PHONY: help up clean

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

build: ## Build the machine image.
	packer validate -var-file=variables.json template.json
	packer build -var-file=variables.json template.json
