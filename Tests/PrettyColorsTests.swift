
import PrettyColors
import Foundation
import XCTest

class PrettyColorsTests: XCTestCase {

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func notTest() {
		Color.Wrap(foreground: .Red).wrap("•••")
		Color.Wrap(foreground: .Yellow, style: .Bold)
		Color.Wrap(foreground: nil as UInt8?)
		// Color.Wrap(style: StyleParameter.Bold)
	}
	
	// Figure out how to do this with XCTest
	func blarg_shouldFail() {
		// println( formerlyRed.add(parameters: Color.EightBit(background: 244)).wrap("•••") )
	}

	func test___Arrgg() {
		var multi = Color.Wrap(parameters: [
			Color.EightBit(foreground: 227),
			Color.Named(foreground: .Green, brightness: .NonBright)
		])
		dump(multi.parameters)
//		formerlyRed.foreground = Color.Named(foreground: .Yellow)
		println( multi.wrap("•••") )
	}

	func testLetWorkflow() {
		let redOnBlack = Color.Wrap(foreground: .Red, background: .Black)
		let boldRedOnBlack = Color.Wrap(parameters: redOnBlack.parameters + [ StyleParameter.Bold ])
		println( boldRedOnBlack.wrap("•••") )
	}
	
	func testSetForeground() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground = Color.EightBit(foreground: 227) // A nice yellow
		println( formerlyRed.wrap("•••") )
	}
	
	func testSetForegroundToNil() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground = nil
		println( formerlyRed.wrap("•••") )
	}

	func testSetForegroundToParameter() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground = StyleParameter.Bold
		println( formerlyRed.wrap("•••") )
	}
	
	func testTransformForeground() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground { (color: ColorType) -> ColorType in
			return Color.EightBit(foreground: 227) // A nice yellow
		}
		println( formerlyRed.wrap("•••") )
	}

	func testTransformForeground2() {
		var formerlyRed = Color.Wrap(foreground: 124)
		formerlyRed.foreground { (var color: ColorType) -> ColorType in
			if let color = color as? Color.EightBit {
				var soonYellow = color
				soonYellow.color += (227-124)
				return soonYellow
			} else { return color }
		}
		println( formerlyRed.wrap("•••") )
	}
	
	func testTransformForegroundWithVar() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground { (var color: ColorType) -> ColorType in
			if let namedColor = color as? Color.Named {
				var soonYellow = namedColor
				soonYellow.color = .Yellow
				return soonYellow
			} else { return color }
		}
		println( formerlyRed.wrap("•••") )
	}

	func testTransformForegroundToBright() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground { (var color: ColorType) -> ColorType in
			var clone = color as Color.Named
			clone.brightness.toggle()
			return clone
		}
		println( formerlyRed.wrap("•••") )
	}

	func testRaceConditions() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground { (var color: ColorType) -> ColorType in
			return Color.Named(foreground: .Yellow)
		}
		println( formerlyRed.wrap("•••") )
	}
	
	func testAddStyleParameter() {
		let red = Color.Wrap(foreground: .Red)
		println( red.add(parameters: .Bold).wrap("•••") )
	}

	
	func blarg_testExample() {
//		XCTAssert(true, "Pass")
//		
//		let red = Color.Wrap(foreground: .Red)
//		let niceColor = Color.Wrap(foreground: 114 as UInt8)
//		for code in ([
//			red,
//			/* none */ { (var __) in
//				__.foreground = nil
//				return __
//			}(red),
//			/* bright red */ { (var red) in
//				red.foreground?.brightness.toggle()
//				return red
//			}(red),
//			niceColor,
//			/* none */ { (var __) in
//				__.foreground = nil
//				return __
//			}(niceColor),
//			niceColor.add(attributes: .Fraktur),
//			/* italic */ { (var __) in
//				__.foreground = nil
//				return __.add(attributes: .Italic)
//			}(niceColor),
//		] as [SelectGraphicRenditionWrapType]) {
//			// dump(code)
//			for i in [
//				code,
//				code.add(attributes: .Bold),
//				code.add(attributes: .Italic, .Underlined),
//				code.add(attributes: .Bold, .Underlined)
//			] {
//				print("••• ")
//				println( i.wrap("__|øat·•ªº^∆©|__") )
//			}
//		}
//
	}

	
}