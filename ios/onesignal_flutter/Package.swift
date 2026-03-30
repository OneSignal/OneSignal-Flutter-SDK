// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "onesignal_flutter",
    platforms: [
        .iOS("11.0")
    ],
    products: [
        .library(name: "onesignal-flutter", targets: ["onesignal_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/OneSignal/OneSignal-iOS-SDK", exact: "5.5.0"),
    ],
    targets: [
        .target(
            name: "onesignal_flutter",
            dependencies: [
                .product(name: "OneSignalFramework", package: "OneSignal-iOS-SDK"),
                .product(name: "OneSignalInAppMessages", package: "OneSignal-iOS-SDK"),
                .product(name: "OneSignalLocation", package: "OneSignal-iOS-SDK"),
                .product(name: "OneSignalExtension", package: "OneSignal-iOS-SDK"),
            ],
            cSettings: [
                .headerSearchPath("include/onesignal_flutter")
            ]
        )
    ]
)
