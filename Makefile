.PHONY: install spm resolve resolve_verify

# Resolve SPM dependencies (none today — this package wraps two vendored
# XCFrameworks — but kept for parity with our other packages).
install:
	@echo "\033[34m→ Resolving Swift Package Manager dependencies...\033[0m"
	@swift package resolve
	@echo "\033[34m✓ Install complete.\033[0m"

# Build the SPM package (iOS Simulator) — verifies the vendored xcframeworks
# are wired correctly and the product actually links.
spm:
	@bash scripts/spm-build.sh

# Resolve SPM dependencies and verify.
resolve:
	@echo "\033[34m→ Resolving SPM dependencies...\033[0m"
	@swift package resolve
	@echo "\033[34m✓ Resolve complete.\033[0m"

# Like `resolve`, but fails if resolving changed the committed Package.resolved
# lockfile. Run this in CI before releasing.
resolve_verify: resolve
	@echo "\033[34m→ Verifying committed lockfile is up to date...\033[0m"
	@if [ -n "$$(git status --porcelain -- '*.resolved')" ]; then \
		echo "\033[31m✗ Package.resolved changed after resolve. Commit the regenerated lockfile:\033[0m"; \
		git status --porcelain -- '*.resolved'; \
		exit 1; \
	fi
	@echo "\033[34m✓ Lockfile up to date.\033[0m"
