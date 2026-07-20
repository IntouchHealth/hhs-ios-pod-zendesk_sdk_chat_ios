// swift-tools-version: 5.7.3
import PackageDescription

let package = Package(
    name: "ZDCChat",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "ZDCChat", targets: ["ZDCChat"]),
    ],
    targets: [
        .binaryTarget(
            name: "ZDCChatBinary",
            path: "ZDCChat.xcframework"
        ),
        .binaryTarget(
            name: "ZDCChatAPIBinary",
            path: "ZDCChatAPI.xcframework"
        ),
        .target(
            name: "ZDCChat",
            dependencies: ["ZDCChatBinary", "ZDCChatAPIBinary"],
            path: "Sources/ZDCChat",
            resources: [
                .copy("Resources/ZDCChat.bundle"),
                .copy("Resources/ZDCChatStrings.bundle"),
            ],
            linkerSettings: [
                .linkedFramework("MobileCoreServices"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("AssetsLibrary"),
            ]
        ),
    ]
)
