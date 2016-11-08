
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
		let redText: String = Color.Wrap(foreground: .red).wrap("A red piece of text.")
		print(redText)
		
		_ = ((
			Color.Wrap(foreground: .yellow, style: .bold),
			Color.Wrap(foreground: .green, background: .black, style: .bold, .underlined),
			
			// 8-bit (256) color support
			Color.Wrap(foreground: 114),
			Color.Wrap(foreground: 114, style: .bold)
		))
	}

	func test_problem_SingleStyleParameter() {
		/*
			As of `swiftlang-700.0.57.3`, the following statement errors:
			«Ambiguous use of 'init(foreground:background:style:)'»
		*/
		// Color.Wrap(style: .bold)
		
		_ = ((
			// Workarounds:
			Color.Wrap(foreground: nil as UInt8?, style: .bold),
			Color.Wrap(foreground: nil as Color.Named.Color?, style: .bold),
			[StyleParameter.bold] as Color.Wrap,
			Color.Wrap(styles: .bold),
			
			// Multiple
			Color.Wrap(styles: .bold, .blink)
		))
	}
	
	func test_problem_TypeInference() {

		// As of `swiftlang-700.0.57.3`, this doesn't get type-inferred properly.
		/*
		Color.Wrap(
			parameters: [
				Color.Named(foreground: .green),
				Color.EightBit(foreground: 114),
				StyleParameter.bold
			]
		)
		*/
		
		_ = ((
			// Workarounds:
			Color.Wrap(
				parameters: [
					Color.Named(foreground: .green),
					Color.EightBit(foreground: 114),
					StyleParameter.bold
				] as [Color.Wrap.Element]
			),

			Color.Wrap(
				parameters: [
					Color.Named(foreground: .green),
					Color.EightBit(foreground: 114),
					StyleParameter.bold
				] as [Parameter]
			),

			[
				Color.Named(foreground: .green),
				Color.EightBit(foreground: 114),
				StyleParameter.bold
			] as Color.Wrap
		))
	}

	func testImmutableFilterOrMap() {
		let redBold = Color.Wrap(foreground: .red, style: .bold)
		let redItalic = Color.Wrap(foreground: .red, style: .italic)
		
		// Filter
		XCTAssert(
			redBold == redItalic
				.filter { $0 != StyleParameter.italic }
				+ [ StyleParameter.bold ]
		)
		
		// Map
		XCTAssert(
			// `ArrayLiteralConvertible` inferred
			[] + redItalic
				.map {
					switch $0 as? StyleParameter {
						case .some: /* replace value */ return StyleParameter.bold
						case .none: /* same value */ return $0
					}
				}
				== redBold
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
		let multi = [
			Color.EightBit(foreground: 227),
			Color.Named(foreground: .green, brightness: .nonBright)
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
		let redOnBlack = Color.Wrap(foreground: .red, background: .black)
		let boldRedOnBlack: Color.Wrap = redOnBlack + [ StyleParameter.bold ] as Color.Wrap
		
		XCTAssert(
			boldRedOnBlack == Color.Wrap(foreground: .red, background: .black, style: .bold)
		)
		XCTAssert(
			[
				boldRedOnBlack,
				Color.Wrap(foreground: .red, background: .black, style: .bold)
			].reduce(true) {
				(previous, value) in
				return previous && value.parameters.reduce(true) {
					(previous, value) in
					// For some reason, referencing `value` avoids the
					// `Expression was too complex to be solved in reasonable time` 
					// error for the returned expression… 😕
					_ = value
					return previous && (
						value == Color.Named(foreground: .red) as Parameter ||
						value == Color.Named(background: .black) as Parameter ||
						value == StyleParameter.bold
					)
				}
			} == true
		)
	}

	
	func testAppendStyleParameter() {
		let red = Color.Wrap(foreground: .red)
		
		let _ = { (wrap: Color.Wrap) -> Void in
			var formerlyRed = wrap
			formerlyRed.append(StyleParameter.bold)
			XCTAssert(
				formerlyRed == Color.Wrap(foreground: .red, style: .bold)
			)
		}(red)
		
		let _ = { (wrap: Color.Wrap) -> Void in
			var formerlyRed = wrap
			formerlyRed.append(style: .bold)
			XCTAssert(
				formerlyRed == Color.Wrap(foreground: .red, style: .bold)
			)
		}(red)
		
		XCTAssert(
			red + Color.Wrap(styles: .bold) == Color.Wrap(foreground: .red, style: .bold)
		)
		
		// Multiple
		let _ = { (wrap: Color.Wrap) -> Void in
			var formerlyRed = wrap
			formerlyRed.append(StyleParameter.bold)
			formerlyRed.append(StyleParameter.italic)
			XCTAssert(
				formerlyRed == Color.Wrap(foreground: .red, style: .bold, .italic)
			)
		}(red)
		
		let _ = { (wrap: Color.Wrap) -> Void in
			var formerlyRed = wrap
			formerlyRed.append(style: .bold, .italic)
			XCTAssert(
				formerlyRed == Color.Wrap(foreground: .red, style: .bold, .italic)
			)
		}(red)

		XCTAssert(
			red + Color.Wrap(styles: .bold, .italic) == Color.Wrap(foreground: .red, style: .bold, .italic)
		)
	}

	func testMutableAppend() {
		var formerlyRed = Color.Wrap(foreground: .red)
		let redBlackBackground = Color.Wrap(foreground: .red, background: .black)
		
		
		formerlyRed.append( Color.Named(background: .black) )
		
		XCTAssert(
			formerlyRed == redBlackBackground
		)
	}
	
	//------------------------------------------------------------------------------
	// MARK: - Foreground/Background
	//------------------------------------------------------------------------------
	
	func testSetForeground() {
		var formerlyRed = Color.Wrap(foreground: .red)
		formerlyRed.foreground = Color.EightBit(foreground: 227) // A nice yellow
		XCTAssert(
			formerlyRed == Color.Wrap(foreground: 227)
		)
	}
		
	func testSetForegroundToNil() {
		var formerlyRed = Color.Wrap(foreground: .red)
		formerlyRed.foreground = nil
		
		XCTAssert(
			formerlyRed == Color.Wrap(foreground: nil as Color.Named.Color?)
		)
		XCTAssert(
			formerlyRed == Color.Wrap(foreground: nil as UInt8?)
		)
	}

	func testSetForegroundToParameter() {
		var formerlyRed = Color.Wrap(foreground: .red)
		formerlyRed.foreground = StyleParameter.bold
		
		XCTAssert( formerlyRed == [StyleParameter.bold] as Color.Wrap )

	}
	
	func testTransformForeground() {
		var formerlyRed = Color.Wrap(foreground: .red)
		_ = formerlyRed.foreground { _ in
			return Color.EightBit(foreground: 227) // A nice yellow
		}
		XCTAssert( formerlyRed == Color.Wrap(foreground: 227) )
	}

	func testTransformForeground2() {
		var formerlyRed = Color.Wrap(foreground: 124)
		_ = formerlyRed.foreground { color in
			guard var soonYellow = color as? Color.EightBit else { return color }
			soonYellow.color += (227 as UInt8 - 124)
			return soonYellow
		}
		XCTAssert( formerlyRed == Color.Wrap(foreground: 227) )
	}
	
	func testTransformForegroundWithVar() {
		var formerlyRed = Color.Wrap(foreground: .red)
		_ = formerlyRed.foreground { color in
			if let namedColor = color as? Color.Named {
				var soonYellow = namedColor
				soonYellow.color = .yellow
				return soonYellow
			} else { return color }
		}
		XCTAssert( formerlyRed == Color.Wrap(foreground: .yellow) )
	}

	func testTransformForegroundToBright() {
		var formerlyRed = Color.Wrap(foreground: .red)
		
		_ = formerlyRed.foreground {
			var clone = $0 as! Color.Named
			clone.brightness.toggle()
			return clone
		}
		
		let brightRed = [
			Color.Named(foreground: .red, brightness: .bright)
		] as Color.Wrap
		
		XCTAssert( formerlyRed == brightRed )
	}
	
	func testComputedVariableForegroundEquality() {
		XCTAssert(
			Color.Named(foreground: .red) == Color.Wrap(foreground: .red).foreground! as! Color.Named
		)
	}

	func testEightBitForegroundBackgroundDifference() {
		let foreground = Color.Named(foreground: .green).code.enable
		let background = Color.Named(background: .green).code.enable
		
		let difference = zip(foreground, background)
			.reduce(0 as UInt8) { sum, values in
				let (foreground, background) = values
				return sum + background - foreground
			}
		
		XCTAssert( difference == 10 )
	}

	func testNamedForegroundBackgroundDifference() {
		let foreground = Color.Named(foreground: .green).code.enable
		let background = Color.Named(background: .green).code.enable
		
		let difference = zip(foreground, background)
			.reduce(0 as UInt8) { sum, values in
				let (foreground, background) = values
				return sum + background - foreground
			}
		
		XCTAssert( difference == 10 )
	}
	
	func testNamedBrightnessDifference() {
		let non·bright = Color.Named(foreground: .green).code.enable
		let bright = Color.Named(foreground: .green, brightness: .bright).code.enable
		
		let difference = zip(non·bright, bright)
			.reduce(0 as UInt8) { sum, values in
				let (non·bright, bright) = values
				return sum + bright - non·bright
			}
		
		XCTAssert( difference == 60 )
	}
	
	//------------------------------------------------------------------------------
	// MARK: - Zap
	//------------------------------------------------------------------------------
	
	func testZapAllStyleParameters() {
	
		for wrap in [
			Color.Wrap(foreground: .red),
			Color.Wrap(foreground: 114)
		] {
			for (number, style·wrap): (UInt8, Color.Wrap) in (
				(1 as UInt8 ... 55).flatMap /* more accurately, concatenate optionals */ {
					guard let style = StyleParameter(rawValue: $0) else { return nil }
					return ($0 as UInt8, [style] as Color.Wrap)
				}
			) {
				let formatted·number = NSString(format: "%02d", number) as String

				for (appended·wrap, suffix) in [
					(wrap, "normal"),
					// TODO: Investigate why `as (Color.Wrap, String)` before above comma 
					// doesn't provide enough type info for the remaining lines in the array.
					(wrap + [ StyleParameter.bold ], "bold"),
					(wrap + [ StyleParameter.italic ], "italic"),
					(wrap + [ StyleParameter.underlined ], "underlined")
				] /* type-inference fails without */ as [(Color.Wrap, String)] {
					let styled·output = (appended·wrap + style·wrap).wrap("__|øat·•ªº^∆©|__")
					print( "• \(styled·output) \(formatted·number) + \(suffix)" )
				}
			}
		}

	}

}
