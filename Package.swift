// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BusyTabs",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "BusyTabs",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "BusyTabsTests",
            dependencies: ["BusyTabs"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
