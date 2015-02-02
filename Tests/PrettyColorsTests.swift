
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
	
	func test_basics() {
		let redText: String = Color.Wrap(foreground: .Red).wrap("A red piece of text.")
		println(redText)
		
		Color.Wrap(foreground: .Yellow, style: .Bold)
		Color.Wrap(foreground: .Green, background: .Black, style: .Bold, .Underlined)
		
		// 8-bit (256) color support
		Color.Wrap(foreground: 114)
		Color.Wrap(foreground: 114, style: .Bold)
	}

	func test_problem_SingleStyleParameter() {
		/*
			As of `swift-600.0.57.3`, the following statement errors:
			«Extra argument 'style' in call»
		*/
		// Color.Wrap(style: .Bold)

		/*
			Removing the supposedly "extra" argument 'style' errors:
			«'().Type' does not have a member named 'Bold'»
		*/
		// Color.Wrap(.Bold)
		
		/*
			The true problem appears to be the ambiguity between the 
			two functions of the form `init(foreground:background:style:)`.
		*/
		
		// Workarounds:
		Color.Wrap(foreground: nil as UInt8?, style: .Bold)
		Color.Wrap(foreground: nil as Color.Named.Color?, style: .Bold)
		[StyleParameter.Bold] as Color.Wrap
		Color.Wrap(styles: .Bold)
		
		// Multiple
		Color.Wrap(styles: .Bold, .Blink)
	}
	
	func test_problem_TypeInference() {

		// As of `swift-600.0.57.3`, this doesn't get type-inferred properly.
		/*
		Color.Wrap(
			parameters: [
				Color.Named(foreground: .Green),
				Color.EightBit(foreground: 114),
				StyleParameter.Bold
			]
		)
		*/

		// Workarounds:
		Color.Wrap(
			parameters: [
				Color.Named(foreground: .Green),
				Color.EightBit(foreground: 114),
				StyleParameter.Bold
			] as [Color.Wrap.Element]
		)

		Color.Wrap(
			parameters: [
				Color.Named(foreground: .Green),
				Color.EightBit(foreground: 114),
				StyleParameter.Bold
			] as [Parameter]
		)

		[
			Color.Named(foreground: .Green),
			Color.EightBit(foreground: 114),
			StyleParameter.Bold
		] as Color.Wrap

	}

	func testImmutableFilterOrMap() {
		let redBold = Color.Wrap(foreground: .Red, style: .Bold)
		let redItalic = Color.Wrap(foreground: .Red, style: .Italic)
		
		XCTAssert(
			redBold == redItalic
				.filter { $0 != StyleParameter.Italic }
				+ [ StyleParameter.Bold ]
		)
		
		XCTAssert(
			redBold == Color.Wrap(
				parameters: redItalic
					.map { (parameter: Parameter) in
						return parameter == StyleParameter.Italic
						? StyleParameter.Bold
						: parameter
					}
			)
		)

	}

	func testEmptyWrap() {
		XCTAssert(
			Color.Wrap(parameters: []).code.enable == "",
			"Wrap with no parameters wrapping an empty string should return an empty SelectGraphicRendition."
		)
		XCTAssert(
			Color.Wrap(parameters: []).wrap("") == "",
			"Wrap with no parameters wrapping an empty string should return an empty string."
		)
	}
	
	func testMulti() {
		var multi = [
			Color.EightBit(foreground: 227),
			Color.Named(foreground: .Green, brightness: .NonBright)
		] as Color.Wrap
		XCTAssert(
			multi.code.enable ==
			ECMA48.controlSequenceIntroducer + "38;5;227" + ";" + "32" + "m"
		)
		XCTAssert(
			multi.code.disable ==
			ECMA48.controlSequenceIntroducer + "0" + "m"
		)
	}

	func testLetWorkflow() {
		let redOnBlack = Color.Wrap(foreground: .Red, background: .Black)
		let boldRedOnBlack: Color.Wrap = redOnBlack + [ StyleParameter.Bold ] as Color.Wrap
		
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

	
	func testAppendStyleParameter() {
		let red = Color.Wrap(foreground: .Red)
		
		let _ = { (wrap: Color.Wrap) -> Void in
			var formerlyRed = wrap
			formerlyRed.append(StyleParameter.Bold)
			XCTAssert(
				formerlyRed == Color.Wrap(foreground: .Red, style: .Bold)
			)
		}(red)
		
		let _ = { (wrap: Color.Wrap) -> Void in
			var formerlyRed = wrap
			formerlyRed.append(style: .Bold)
			XCTAssert(
				formerlyRed == Color.Wrap(foreground: .Red, style: .Bold)
			)
		}(red)
		
		XCTAssert(
			red + Color.Wrap(styles: .Bold) == Color.Wrap(foreground: .Red, style: .Bold)
		)
		
		// Multiple
		let _ = { (wrap: Color.Wrap) -> Void in
			var formerlyRed = wrap
			formerlyRed.append(StyleParameter.Bold)
			formerlyRed.append(StyleParameter.Italic)
			XCTAssert(
				formerlyRed == Color.Wrap(foreground: .Red, style: .Bold, .Italic)
			)
		}(red)
		
		let _ = { (wrap: Color.Wrap) -> Void in
			var formerlyRed = wrap
			formerlyRed.append(style: .Bold, .Italic)
			XCTAssert(
				formerlyRed == Color.Wrap(foreground: .Red, style: .Bold, .Italic)
			)
		}(red)

		XCTAssert(
			red + Color.Wrap(styles: .Bold, .Italic) == Color.Wrap(foreground: .Red, style: .Bold, .Italic)
		)
	}

	func testMutableAppend() {
		var formerlyRed = Color.Wrap(foreground: .Red)
		let redBlackBackground = Color.Wrap(foreground: .Red, background: .Black)
		
		
		formerlyRed.append( Color.Named(background: .Black) )
		
		XCTAssert(
			formerlyRed == redBlackBackground
		)
	}
	
	//------------------------------------------------------------------------------
	// MARK: - Foreground/Background
	//------------------------------------------------------------------------------
	
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
		
		XCTAssert( formerlyRed == [StyleParameter.Bold] as Color.Wrap )

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
		
		let brightRed = [
			Color.Named(foreground: .Red, brightness: .Bright)
		] as Color.Wrap
		
		XCTAssert( formerlyRed == brightRed )
	}
	
	func testComputedVariableForegroundEquality() {
		XCTAssert(
			Color.Named(foreground: .Red) == Color.Wrap(foreground: .Red).foreground! as Color.Named
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
	
	//------------------------------------------------------------------------------
	// MARK: - Zap
	//------------------------------------------------------------------------------
	
	func testZapAllStyleParameters() {
		
		let red = Color.Named(foreground: .Red)
		let niceColor = Color.EightBit(foreground: 114)
		
		let iterables: Array<Array<Parameter>> = [
			[red],
			[niceColor],
		]
	
		for parameters in iterables {

			let wrap = Color.Wrap(parameters: parameters)
			
			for i in stride(from: 1 as UInt8, through: 55, by: 1) {
				if let parameter = StyleParameter(rawValue: i) {
					for wrapAndSuffix in [
						(wrap, "normal"),
						(wrap + [ StyleParameter.Bold ] as Color.Wrap, "bold"),
						(wrap + [ StyleParameter.Italic ] as Color.Wrap, "italic"),
						(wrap + [ StyleParameter.Underlined ] as Color.Wrap, "underlined")
					] {
						let wrap = (wrapAndSuffix.0 + [parameter] as Color.Wrap)
						let suffix = wrapAndSuffix.1
						let string = "• " + wrap.wrap("__|øat·•ªº^∆©|__") +
							" " + NSString(format: "%02d", i) + " + " + suffix
						println(string)
					}
				}
			}
		}
	}

}
