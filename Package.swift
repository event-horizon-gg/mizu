// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "Mizu",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "Mizu", targets: ["Mizu"])],
    dependencies: [.package(url: "https://github.com/EmergeTools/Pow", exact: "1.0.6")],
    targets: [.target(name: "Mizu", dependencies: [.product(name: "Pow", package: "Pow")],
                      resources: [.copy("Resources/Pow-LICENSE.txt")])]
)
