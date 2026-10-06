// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "Mizu",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "Mizu", targets: ["Mizu"])],
    targets: [.target(name: "Mizu")]
)
