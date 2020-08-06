// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "coolc",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Antlr4", url: "~/workspace/antlr4/antlr4/runtime/Swift/Antlr4-tmp-1596662343", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "coolc",
            dependencies: ["Antlr4"]),
        .testTarget(
            name: "coolcTests",
            dependencies: ["coolc"]),
    ]
)
