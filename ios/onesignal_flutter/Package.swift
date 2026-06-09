// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

func oneSignalEnvFlag(_ name: String) -> Bool {
    let value = Context.environment[name]?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return value == "true" || value == "1"
}

let oneSignalDisableLocation = oneSignalEnvFlag("ONESIGNAL_DISABLE_LOCATION")

var oneSignalDependencies: [Target.Dependency] = [
    .product(name: "OneSignalFramework", package: "OneSignal-XCFramework"),
    .product(name: "OneSignalInAppMessages", package: "OneSignal-XCFramework"),
    .product(name: "OneSignalExtension", package: "OneSignal-XCFramework"),
]

if !oneSignalDisableLocation {
    oneSignalDependencies.append(.product(name: "OneSignalLocation", package: "OneSignal-XCFramework"))
}

let oneSignalDisableLocation = Context.environment["ONESIGNAL_DISABLE_LOCATION"] == "true"

var oneSignalDependencies: [Target.Dependency] = [
    .product(name: "OneSignalFramework", package: "OneSignal-XCFramework"),
    .product(name: "OneSignalInAppMessages", package: "OneSignal-XCFramework"),
    .product(name: "OneSignalExtension", package: "OneSignal-XCFramework"),
]

if !oneSignalDisableLocation {
    oneSignalDependencies.append(.product(name: "OneSignalLocation", package: "OneSignal-XCFramework"))
}

let package = Package(
    name: "onesignal_flutter",
    platforms: [
        .iOS("11.0")
    ],
    products: [
        .library(name: "onesignal-flutter", targets: ["onesignal_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/OneSignal/OneSignal-XCFramework", exact: "5.5.2"),
    ],
    targets: [
        .target(
            name: "onesignal_flutter",
            dependencies: oneSignalDependencies,
            cSettings: [
                .headerSearchPath("include/onesignal_flutter")
            ]
        )
    ]
)
