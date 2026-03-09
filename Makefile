SHELL=/bin/bash
DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Available targets:"
	@echo ""
	@echo "Development:"
	@echo "  serve        - Build and serve the documentation locally"
	@echo ""
	@echo "Cleanup:"
	@echo "  clean        - Remove the local documentation builder image"
	@echo ""
	@echo "Help:"
	@echo "  help         - Show this help message"

.PHONY: serve
serve:
	./mkdocs-helper.sh

.PHONY: clean
clean:
	docker rmi sceptre-phenix-docs-builder || true
