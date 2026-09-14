SCHEME     := RightClickMenu
APP_NAME   := Right Click Menu
BUNDLE_ID  := com.willlattus.right-click-menu
EXT_ID     := $(BUNDLE_ID).finder-extension

# Your team id lives in .env, which is never committed. Copy sample.env to start.
-include .env
export TEAM_ID

INSTALL_DIR := /Applications
APP        := $(INSTALL_DIR)/$(APP_NAME).app
BUILT      := .dist/Build/Products/Debug/$(APP_NAME).app
PACKAGE    := Packages/RightClickMenu

.DEFAULT_GOAL := help
.PHONY: help bootstrap gen build test lint run install register enable diagnose clean

help:
	@echo "make bootstrap   install xcodegen + swiftlint, check signing identity"
	@echo "make test        the test run. swift test in $(PACKAGE). no Xcode"
	@echo "make lint        swiftlint"
	@echo "make run         build, install, register the extension, restart Finder, launch"
	@echo "make diagnose    is the extension registered and enabled? any sandbox denials?"
	@echo "make clean       remove build products and the generated project"

bootstrap:
	@./scripts/bootstrap.sh

gen:
	@test -n "$(TEAM_ID)" || { \
		echo "No TEAM_ID. Copy sample.env to .env and put your Apple team id in it."; \
		exit 1; \
	}
	@xcodegen generate --quiet
	@echo "generated $(SCHEME).xcodeproj"

test:
	@swift test --package-path $(PACKAGE)

lint:
	@swiftlint lint --quiet --strict

build: gen
	@xcodebuild -project $(SCHEME).xcodeproj -scheme $(SCHEME) \
		-configuration Debug -derivedDataPath .dist \
		-destination 'platform=macOS' build | \
		grep -E "error:|warning:|BUILD" || true

run: build install register
	@killall Finder 2>/dev/null || true
	@open "$(APP)"
	@echo
	@echo "Running. Right-click the Desktop."
	@echo "If the entry is missing, run: make diagnose"

install:
	@mkdir -p "$(INSTALL_DIR)"
	@rm -rf "$(APP)"
	@ditto "$(BUILT)" "$(APP)"
	@echo "installed $(APP)"

register:
	@pluginkit -r "$(BUILT)/Contents/PlugIns/finder-extension.appex" 2>/dev/null || true
	@pluginkit -a "$(APP)/Contents/PlugIns/finder-extension.appex" 2>/dev/null || true
	@pluginkit -e use -i $(EXT_ID) 2>/dev/null || true
	@echo "registered $(EXT_ID)"

diagnose:
	@echo "== every registered copy (a '=' means a stale duplicate is winning) =="
	@pluginkit -m -A -D -i $(EXT_ID) -vvv 2>/dev/null || echo "  NOT REGISTERED"
	@echo
	@echo "== election: + use, - ignore, ! debugger, = superseded =="
	@pluginkit -m -i $(EXT_ID) 2>/dev/null || echo "  not listed"
	@echo
	@echo "== all FinderSync extensions on this Mac =="
	@pluginkit -m -p com.apple.FinderSync -vvv 2>/dev/null || echo "  none"
	@echo
	@echo "== live log. create a file now, then ctrl-C =="
	@log stream --style compact \
		--predicate 'subsystem == "$(BUNDLE_ID)" OR (eventMessage CONTAINS "deny(" AND eventMessage CONTAINS "right-click")'

clean:
	@rm -rf .dist $(SCHEME).xcodeproj
	@swift package --package-path $(PACKAGE) clean 2>/dev/null || true
	@echo "cleaned"

# Written by hand, not generated. Kept last so the rest stays readable.
