PYTHON ?= python3
LINTER_DIR := tools/package_linter
LINTER_VENV := .venv-package-linter
CHECK_DIR := tools/package_check
CHECK_VENV := .venv-package-check
CHECK_VENV_ABS := $(abspath $(CHECK_VENV))
APP_PATH ?= .
CHECK_ARGS ?=

.PHONY: submodules lint-setup lint check-setup check

submodules:
	git submodule update --init --recursive

lint-setup: submodules
	test -x $(LINTER_VENV)/bin/python || $(PYTHON) -m venv $(LINTER_VENV)
	$(LINTER_VENV)/bin/python -m pip install --upgrade pip
	$(LINTER_VENV)/bin/python -m pip install -r $(LINTER_DIR)/requirements.txt

lint: lint-setup
	tmp_dir=$$(mktemp -d); \
	trap 'rm -rf "$$tmp_dir"' EXIT; \
	tar --exclude=.git --exclude=tools --exclude=$(LINTER_VENV) -cf - . | tar -xf - -C "$$tmp_dir"; \
	$(LINTER_VENV)/bin/python $(LINTER_DIR)/package_linter.py "$$tmp_dir"

check: submodules
check-setup: submodules
	test -x $(CHECK_VENV)/bin/python || $(PYTHON) -m venv $(CHECK_VENV)
	$(CHECK_VENV)/bin/python -m pip install --upgrade pip
	$(CHECK_VENV)/bin/python -m pip install -r $(CHECK_DIR)/requirements.txt

check: check-setup
	tmp_dir=$$(mktemp -d); \
	app_dir="$$tmp_dir/app"; \
	trap 'rm -rf "$$tmp_dir"' EXIT; \
	mkdir -p "$$app_dir"; \
	if [ "$(APP_PATH)" = "." ]; then \
		tar --exclude=.git --exclude=tools --exclude=$(LINTER_VENV) --exclude=$(CHECK_VENV) -cf - . | tar -xf - -C "$$app_dir"; \
	else \
		tar --exclude=.git --exclude=tools --exclude=$(LINTER_VENV) --exclude=$(CHECK_VENV) -cf - "$(APP_PATH)" | tar -xf - -C "$$app_dir"; \
		app_dir="$$app_dir/$(APP_PATH)"; \
	fi; \
	PATH="$(CHECK_VENV_ABS)/bin:$$PATH" bash $(CHECK_DIR)/package_check.sh $(CHECK_ARGS) "$$app_dir"
