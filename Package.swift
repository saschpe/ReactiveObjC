// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReactiveObjC",
    platforms: [
        .iOS(.v8), .macOS(.v10_10), .watchOS(.v2), .tvOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ReactiveObjC",
            targets: ["ReactiveObjC"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ReactiveObjC",
            dependencies: [],
            cSettings: [.headerSearchPath("extobjc"),
                        .define("DTRACE_PROBES_DISABLED", to: "1")]),
    ]
)
