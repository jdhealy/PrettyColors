
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

	func testEmptyWrap() {
		XCTAssert(
			Color.Wrap(foreground: nil as UInt8?).code.enable == "",
			"Wrap with no parameters wrapping an empty string should return an empty SelectGraphicRendition."
		)
		XCTAssert(
			Color.Wrap(foreground: nil as UInt8?).wrap("") == "",
			"Wrap with no parameters wrapping an empty string should return an empty string."
		)
	}
	
	func testMulti() {
		var multi = Color.Wrap(parameters: [
			Color.EightBit(foreground: 227),
			Color.Named(foreground: .Green, brightness: .NonBright)
		])
		XCTAssert(
			multi.code.enable ==
			ECMA48.controlSequenceIntroducer + "38;5;227" + ";" + "32" + "m"
		)
		XCTAssert(
			multi.code.disable ==
			ECMA48.controlSequenceIntroducer + "0" + "m"
		)
	}

	func testWrapComputedVariableForeground() {
		XCTAssert(
			Color.Named(foreground: .Red) == Color.Wrap(foreground: .Red).foreground! as Color.Named
		)
	}
	
	func testLetWorkflow() {
		let redOnBlack = Color.Wrap(foreground: .Red, background: .Black)
		let boldRedOnBlack = Color.Wrap(parameters: redOnBlack.parameters + [ StyleParameter.Bold ])
		
		XCTAssert(
			boldRedOnBlack == Color.Wrap(foreground: .Red, background: .Black, style: .Bold)
		)
		XCTAssert(
			[
				boldRedOnBlack,
				Color.Wrap(foreground: .Red, background: .Black, style: .Bold)
			].reduce(true) {
				(previous, value) in
				return previous && value.parameters.reduce(true) {
					(previous, value) in
					let enable = value.code.enable
					return previous && (
						value == Color.Named(foreground: .Red) as Parameter ||
						value == Color.Named(background: .Black) as Parameter ||
						value == StyleParameter.Bold
					)
				}
			} == true
		)
	}
	
	func testSetForeground() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground = Color.EightBit(foreground: 227) // A nice yellow
		XCTAssert(
			formerlyRed == Color.Wrap(foreground: 227)
		)
	}
	
	func testSetForegroundToNil() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground = nil
		
		XCTAssert(
			formerlyRed == Color.Wrap(foreground: nil as UInt8?)
		)
	}

	func testSetForegroundToParameter() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground = StyleParameter.Bold
		
		XCTAssert( formerlyRed == Color.Wrap(parameters: [StyleParameter.Bold]) )
	}
	
	func testTransformForeground() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground { (color: ColorType) -> ColorType in
			return Color.EightBit(foreground: 227) // A nice yellow
		}
		XCTAssert( formerlyRed == Color.Wrap(foreground: 227) )
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
		XCTAssert( formerlyRed == Color.Wrap(foreground: 227) )
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
		XCTAssert( formerlyRed == Color.Wrap(foreground: .Yellow) )
	}

	func testTransformForegroundToBright() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		formerlyRed.foreground { (var color: ColorType) -> ColorType in
			var clone = color as Color.Named
			clone.brightness.toggle()
			return clone
		}
		
		let brightRed = Color.Wrap(parameters: [
			Color.Named(foreground: .Red, brightness: .Bright)
		])
		
		XCTAssert( formerlyRed == brightRed )
	}
	
	func testAddStyleParameter() {
		let red = Color.Wrap(foreground: .Red)
		
		XCTAssert(
			red.add(parameters: .Bold) as Color.Wrap ==
			Color.Wrap(foreground: .Red, style: .Bold)
		)
	}

	func testEightBitForegroundBackgroundDifference() {
		let one = Color.EightBit(foreground: 114)
		let two = Color.EightBit(background: 114)
		
		let difference = one.code.enable.reduce(
			two.code.enable.reduce(0 as UInt8) { return $0.0 + $0.1 }
		) { return $0.0 - $0.1 }
		
		XCTAssert( difference == 10 )
	}

	func testNamedForegroundBackgroundDifference() {
		let one = Color.Named(foreground: .Green)
		let two = Color.Named(background: .Green)
		
		let difference = one.code.enable.reduce(
			two.code.enable.reduce(0 as UInt8) { return $0.0 + $0.1 }
		) { return $0.0 - $0.1 }
		
		XCTAssert( difference == 10 )
	}
	
	func testNamedBrightnessDifference() {
		let one = Color.Named(foreground: .Green)
		let two = Color.Named(foreground: .Green, brightness: .Bright)
		
		let difference = one.code.enable.reduce(
			two.code.enable.reduce(0 as UInt8) { return $0.0 + $0.1 }
		) { return $0.0 - $0.1 }
		
		XCTAssert( difference == 60 )
	}
	
	func testZapAllStyleParameters() {
		
		let red = Color.Named(foreground: .Red)
		let niceColor = Color.EightBit(foreground: 114)
		
		let iterables: Array< [Parameter] > = [
			[red],
			[niceColor],
		]
	
		for parameters in iterables {

			let wrap = Color.Wrap(parameters: parameters)
			
			for i in stride(from: 1 as UInt8, through: 55, by: 1) {
				if let parameter = StyleParameter(rawValue: i) {
					for modifiedWrap in [
						(wrap, "normal"),
						(wrap.add(parameters: .Bold), "bold"),
						(wrap.add(parameters: .Italic), "italic"),
						(wrap.add(parameters: .Underlined), "underlined")
					] {
						let string = "• " +
							modifiedWrap.0.add(parameters: parameter).wrap("__|øat·•ªº^∆©|__") +
							" " + NSString(format: "%02d", i) + " + " + modifiedWrap.1
						println(string)
					}
				}
			}
		}
	}

}
