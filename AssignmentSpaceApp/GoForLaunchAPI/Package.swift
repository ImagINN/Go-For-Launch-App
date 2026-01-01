// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoForLaunchAPI",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "GoForLaunchAPI",
            targets: ["GoForLaunchAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.10.0")
    ],
    targets: [
        .target(
            name: "GoForLaunchAPI",
            dependencies: ["Alamofire"],
        ),
        .testTarget(
            name: "GoForLaunchAPITests",
            dependencies: ["GoForLaunchAPI"]
        ),
    ]
)
