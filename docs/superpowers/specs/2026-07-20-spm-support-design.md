# SPM support for ZDCChat

## Goal

Add Swift Package Manager support to the ZDCChat repo, alongside the existing
CocoaPods podspec, following the pattern used in `ios-package-thcryptopp`.

## Scope

- New `Package.swift` at repo root exposing a single `ZDCChat` library
  product that wraps the two prebuilt xcframeworks already committed to the
  repo (`ZDCChat.xcframework`, `ZDCChatAPI.xcframework`).
- Makefile + build-verification script, mirroring `ios-package-thcryptopp`.
- README update documenting SPM install.
- `.gitignore` additions for SPM build artifacts.

Out of scope: publishing/tagging process, CI wiring, CocoaPods podspec
changes (root bundle locations stay as-is for CocoaPods).

## Package.swift

- `swift-tools-version: 5.7.3`
- `platforms: [.iOS(.v12)]` — matches podspec's `s.platform = :ios, '12'`.
- Targets:
  - `.binaryTarget(name: "ZDCChatBinary", path: "ZDCChat.xcframework")`
  - `.binaryTarget(name: "ZDCChatAPIBinary", path: "ZDCChatAPI.xcframework")`
  - `.target(name: "ZDCChat", dependencies: ["ZDCChatBinary", "ZDCChatAPIBinary"], path: "Sources/ZDCChat", resources: [...], linkerSettings: [...])`
    - One stub Swift file (`Sources/ZDCChat/ZDCChat.swift`, effectively
      empty) so the target is unambiguously a normal compiled target across
      SPM tool versions, not a resources-only edge case.
    - `resources: [.copy("Resources/ZDCChat.bundle"), .copy("Resources/ZDCChatStrings.bundle")]`
    - `linkerSettings: [.linkedFramework("MobileCoreServices"), .linkedFramework("SystemConfiguration"), .linkedFramework("AVFoundation"), .linkedFramework("AssetsLibrary")]`
      (mirrors podspec's `UI`/`API` subspec `frameworks` entries)
- Single product: `.library(name: "ZDCChat", targets: ["ZDCChat"])`. No
  separate API-only product — matches the podspec's `default_subspecs`
  behavior (nobody installs API alone in practice).

## Resources

`ZDCChat.bundle` and `ZDCChatStrings.bundle` currently live at repo root and
are referenced from there by `ZDCChat.podspec`. For SPM, resource paths must
live under the target's own directory, so they are **copied** (not moved)
into `Sources/ZDCChat/Resources/`:

- `Sources/ZDCChat/Resources/ZDCChat.bundle`
- `Sources/ZDCChat/Resources/ZDCChatStrings.bundle`

Root copies are left untouched — `ZDCChat.podspec` is unchanged. This means
two copies of ~350KB of bundle data exist in the repo; each future SDK bundle
update must update both copies (call out in README/CHANGELOG when that
happens).

## Makefile / build verification

Mirrors `ios-package-thcryptopp` exactly:

- `Makefile` targets: `install`, `spm`, `resolve`, `resolve_verify` (same
  recipes, same phony declarations).
- `scripts/spm-build.sh`: resolves repo root, runs
  `xcodebuild build -scheme ZDCChat -destination 'generic/platform=iOS Simulator' -skipMacroValidation -skipPackagePluginValidation CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO`.

## .gitignore additions

```
/.build
.swiftpm/config/registries.json
.swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata
```

## README

Add an SPM install snippet next to the existing CocoaPods snippet, e.g.:

```
.package(url: "https://github.com/IntouchHealth/hhs-ios-pod-zendesk_sdk_chat_ios.git", from: "1.4.7")
```

with product name `ZDCChat`.

## Testing / verification

- `make resolve` — package resolves with no dependencies.
- `make spm` — package builds for iOS Simulator via the wrapping scheme,
  proving the binary targets link and the linked frameworks are declared
  correctly.
- No unit tests (prebuilt binary xcframeworks, nothing to test at package
  level) — matches reference package.
