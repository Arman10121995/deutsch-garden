# DeutschGarden — local development.
#
#   make            list the targets
#   make setup      one-time: fetch packages and generate the native wrapper
#   make verify     what CI runs: content check, analyze, tests
#   make run        launch the app with hot reload
#
# Windows: use .\dev.ps1 instead (same commands).

SHELL := /bin/bash
UNAME := $(shell uname -s)

ifeq ($(UNAME),Darwin)
HOST_TARGET := macos
else
HOST_TARGET := linux
endif

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this list
	@echo 'DeutschGarden — local development'
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "Host desktop target detected: $(HOST_TARGET)"

.PHONY: doctor
doctor: ## Check that your Flutter toolchain is complete
	flutter doctor -v

.PHONY: setup
setup: ## Generate the native wrapper for this machine and fetch packages
	./bootstrap.sh all

.PHONY: deps
deps: ## Fetch Dart packages only
	flutter pub get

.PHONY: content
content: ## Validate the bundled curriculum (no Flutter needed)
	python3 tool/validate_content.py

.PHONY: analyze
analyze: ## Static analysis — must be clean before committing
	flutter analyze

.PHONY: test
test: ## Run the test suite
	flutter test

.PHONY: verify
verify: content analyze test ## Everything CI checks, in one command
	@echo
	@echo "All checks passed."

.PHONY: fmt
fmt: ## Format all Dart sources
	dart format lib test

.PHONY: run
run: ## Run on this desktop with hot reload
	flutter run -d $(HOST_TARGET)

.PHONY: run-android
run-android: ## Run on a connected Android device or emulator
	flutter run -d android

.PHONY: devices
devices: ## List devices Flutter can run on right now
	flutter devices

.PHONY: build-android build-linux build-macos build-ios
build-android: ## Release APK
	flutter build apk --release
	@echo "-> build/app/outputs/flutter-apk/app-release.apk"

build-linux: ## Release Linux bundle
	flutter build linux --release
	@echo "-> build/linux/x64/release/bundle/"

build-macos: ## Release macOS .app
	flutter build macos --release
	@echo "-> build/macos/Build/Products/Release/"

build-ios: ## Release iOS build (signing required to install)
	flutter build ios --release
	@echo "-> open ios/Runner.xcworkspace in Xcode to sign and run"

.PHONY: report
report: ## Regenerate every derived file (manifest, report, build_info, tree, checksums)
	python3 tool/validate_content.py --write
	@tail -n 8 VALIDATION_REPORT.txt

.PHONY: clean
clean: ## Remove build output and generated native wrappers
	flutter clean
	rm -rf android ios linux macos windows web .dart_tool build
	@echo "Generated wrappers removed. Run 'make setup' to recreate them."
