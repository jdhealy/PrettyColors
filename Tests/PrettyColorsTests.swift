
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

	func testIterate() {
		let red = Color.Named(foreground: .Red)
		let niceColor = Color.EightBit(foreground: 114)
		
		let iterables: Array< [Parameter] > = [
			[red],
			[], /* none */
			[
				{ (var red) in
					red.brightness.toggle()
					return red
				}(red)
			], /* bright red */
			[niceColor],
			[], /* none */
			[niceColor, StyleParameter.Italic],
		]
			
		for parameters in iterables {

			let wrap = Color.Wrap(parameters: parameters)

			for modifiedWrap in [
				wrap,
				wrap.add(parameters: .Faint),
				wrap.add(parameters: .Bold),
				wrap.add(parameters: .Italic, .Underlined),
				wrap.add(parameters: .Bold, .Underlined)
			] {
				println( "o " + modifiedWrap.wrap("__|øat·•ªº^∆©|__") )
			}
			
		}
	}

	func testZZZ_Everything() {
		
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
						wrap,
						wrap.add(parameters: .Bold),
						wrap.add(parameters: .Italic),
						wrap.add(parameters: .Underlined)
					] {
						println( "\(i)o " + modifiedWrap.add(parameters: parameter).wrap("__|øat·•ªº^∆©|__") )
					}
				}
			}
		}
	}

}
