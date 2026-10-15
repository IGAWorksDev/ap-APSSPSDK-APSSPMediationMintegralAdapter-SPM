// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "APSSPMediationMintegral",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "APSSPMediationMintegral", targets: ["APSSPMediationMintegral"]),
    ],
    dependencies: [
        .package(url: "https://github.com/IGAWorksDev/ap-APSSPSDK-SPM.git", from: "3.4.0"),
        .package(url: "https://github.com/Mintegral-official/MintegralAdSDK-Swift-Package.git", exact: "8.0.6"),
    ],
    targets: [
        .target(name: "APSSPMediationMintegral",
                dependencies: [
                    .product(name: "APSSPSDK", package: "ap-APSSPSDK-SPM"),
                    .product(name: "MintegralAdSDK", package: "MintegralAdSDK-Swift-Package"),
                ],
                path: "Sources/MediationMintegral"),
    ]
)
