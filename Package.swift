// swift-tools-version:3.1

import PackageDescription

var package = Package(
	name: "PrettyColors",
	exclude: ["Supporting Files", "Tests/Supporting Files"]
)

package.targets += [
	Target(
		name: "UnitTests",
		dependencies: ["PrettyColors"]
	)
]
