# Makefile for Final Descent
# Cross-platform development commands
# Works on Linux, macOS, and Windows (with Make installed)

.PHONY: test tests run-tests help clean setup install-deps dev
.DEFAULT_GOAL := help

# Detect OS for cross-platform commands
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    GODOT_PATHS := "C:/Development/Godot 4/Godot_v4.4.1-stable_win64_console.exe" \
                   "C:/Program Files/Godot/godot.exe" \
                   "C:/Program Files (x86)/Godot/godot.exe" \
                   godot godot.exe
    RM := del /q /f
    RMDIR := rmdir /s /q
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        DETECTED_OS := Linux
        GODOT_PATHS := godot /usr/bin/godot /usr/local/bin/godot ~/.local/bin/godot
    endif
    ifeq ($(UNAME_S),Darwin)
        DETECTED_OS := macOS
        GODOT_PATHS := godot /Applications/Godot.app/Contents/MacOS/Godot /usr/local/bin/godot
    endif
    RM := rm -f
    RMDIR := rm -rf
endif

# Find Godot executable
GODOT_CMD := $(shell \
    for path in $(GODOT_PATHS); do \
        if command -v "$$path" >/dev/null 2>&1 || [ -f "$$path" ]; then \
            echo "$$path"; \
            break; \
        fi; \
    done)

# Default target - show help
help:
	@echo "Final Descent Development Commands"
	@echo "=================================="
	@echo ""
	@echo "Testing:"
	@echo "  test         - Run all tests"
	@echo "  tests        - Alias for test"
	@echo "  run-tests    - Alias for test"
	@echo "  test filter=name - Run tests matching filter"
	@echo "  test failed_only=true - Run only previously failed tests"
	@echo ""
	@echo "Development:"
	@echo "  clean        - Clean temporary files"
	@echo "  setup        - Verify development setup"
	@echo "  dev          - Show development info"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make test"
	@echo "  make test filter=ScrollTest"
	@echo "  make test failed_only=true"
	@echo "  make clean"
	@echo "  make setup"
	@echo ""
	@echo "Platform: $(DETECTED_OS)"
	@if [ -n "$(GODOT_CMD)" ]; then \
		echo "Godot: Found at $(GODOT_CMD)"; \
	else \
		echo "Godot: Not found"; \
	fi

# Verify project setup
setup:
	@echo "Verifying Final Descent setup..."
	@echo "Platform: $(DETECTED_OS)"
	@if [ ! -f "project.godot" ]; then \
		echo "Error: project.godot not found. Are you in the project root?"; \
		exit 1; \
	fi
	@echo "[OK] Project file found"
	@if [ ! -d "test" ]; then \
		echo "Error: test directory not found"; \
		exit 1; \
	fi
	@echo "[OK] Test directory found"
	@if [ ! -f "test/test_runner.tscn" ]; then \
		echo "Error: test_runner.tscn not found"; \
		exit 1; \
	fi
	@echo "[OK] Test runner found"
	@if [ -z "$(GODOT_CMD)" ]; then \
		echo "Error: Godot executable not found"; \
		echo "Please install Godot or add it to your PATH"; \
		exit 1; \
	fi
	@echo "[OK] Godot found: $(GODOT_CMD)"
	@echo "Setup verification complete!"

# Run tests
test tests run-tests: setup
	@echo "Running Final Descent tests..."
ifdef filter
	@echo "Filtering tests by: $(filter)"
ifdef failed_only
	@echo "Running only previously failed tests"
	@"$(GODOT_CMD)" --headless --path . res://test/test_runner.tscn -- filter $(filter) failed_only
else
	@"$(GODOT_CMD)" --headless --path . res://test/test_runner.tscn -- filter $(filter)
endif
else ifdef failed_only
	@echo "Running only previously failed tests"
	@"$(GODOT_CMD)" --headless --path . res://test/test_runner.tscn -- failed_only
else
	@"$(GODOT_CMD)" --headless --path . res://test/test_runner.tscn
endif

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
ifeq ($(DETECTED_OS),Windows)
	@-rm -f *.tmp 2>/dev/null || true
	@-rm -f *.log 2>/dev/null || true
	@-rm -rf .godot 2>/dev/null || true
else
	@find . -name "*.tmp" -type f -delete 2>/dev/null || true
	@find . -name "*.log" -type f -delete 2>/dev/null || true
	@rm -rf .godot 2>/dev/null || true
endif
	@echo "Clean complete."

# Development information
dev:
	@echo "Final Descent Development Info"
	@echo "=============================="
	@echo ""
	@echo "Project Structure:"
	@echo "  src/        - Source code"
	@echo "  test/       - Automated tests"
	@echo "  data/       - Game data (.tres files)"
	@echo "  docs/       - Documentation"
	@echo ""
	@echo "Key Files:"
	@echo "  project.godot        - Main project file"
	@echo "  test/test_runner.tscn - Test runner scene"
	@echo "  docs/testing-guide.md - Testing documentation"
	@echo ""
	@echo "Quick Commands:"
	@echo "  make test   - Run all tests"
	@echo "  make clean  - Clean temporary files"
	@echo "  make setup  - Verify setup"