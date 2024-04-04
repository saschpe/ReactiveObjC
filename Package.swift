// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "ReactiveObjC",
    platforms: [
        .iOS(.v12), .macOS(.v10_13), .watchOS(.v4), .tvOS(.v12)
    ],
    products: [
        .library(name: "ReactiveObjC", targets: ["ReactiveObjC"]),
    ],
    targets: [
        .target(
            name: "ReactiveObjC",
            publicHeadersPath: "Public",
            cSettings: [.headerSearchPath("extobjc"),
                        .headerSearchPath("include"),
                        .define("DTRACE_PROBES_DISABLED", to: "1")]),
        .testTarget(
            name: "ReactiveObjCUnit",
            dependencies: [ "ReactiveObjC" ],
            path: "Tests/Unit",
            cSettings: [
                .define("TARGET_OS_IOS", to: "1"),
            ]
        )
    ]
)
