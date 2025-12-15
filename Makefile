skk.DEFAULT_GOAL := help
.SILENT:
.PHONY: help

help:  ## Display this help
	awk 'BEGIN {FS = ":.*## "; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Keymaps Utils

show_terminal_vision: ## Show how terminal map pressed keys
	sudo showkey -a
