// swift-tools-version:3.1

import PackageDescription

var package = Package(
	name: "PrettyColors",
	exclude: ["Supporting Files", "Tests/Supporting Files"]
)

// NOTE: Unchecked presumption that we are not cross-compiling tests to be
// run on another platform. The conditional compilation check for `macOS`
// is intended to only provide support for Darwin XCTest for the time being.
#if os(macOS)
	package.targets += [
		Target(
			name: "UnitTests",
			dependencies: ["PrettyColors"]
		)
	]
#else
	package.exclude += ["Tests"]
#endif
