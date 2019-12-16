// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Charts",
  platforms: [
    .iOS(.v11),
    .tvOS(.v11)
  ],
  products: [
    .library(
      name: "Charts",
      targets: ["Charts"]
    ),
  ],
  targets: [
    .target(
      name: "Charts",
      path: "Charts/Classes"
    ),
  ],
  swiftLanguageVersions: [
    .v5
  ]
)
