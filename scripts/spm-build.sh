#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

printf '\033[34m→ Building SPM package (iOS Simulator)...\033[0m\n'
cd "$REPO_ROOT"

xcodebuild build \
    -scheme ZDCChat \
    -destination 'generic/platform=iOS Simulator' \
    -skipMacroValidation \
    -skipPackagePluginValidation \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO
BUILD_EXIT=$?

if [[ $BUILD_EXIT -eq 0 ]]; then
    printf '\033[32m✓ SPM build succeeded.\033[0m\n'
else
    printf '\033[31m✗ SPM build failed (exit %d).\033[0m\n' "$BUILD_EXIT"
fi

exit $BUILD_EXIT
