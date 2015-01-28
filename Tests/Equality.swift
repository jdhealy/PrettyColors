
import PrettyColors
import Foundation
import XCTest

class EqualityTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testA() {
		let one = [
			Color.EightBit(foreground: 100),
			Color.EightBit(background: 200),
			(StyleParameter.Encircled)
		] as Color.Wrap
		
		let two = [
			Color.EightBit(background: 200),
			StyleParameter.Encircled,
			Color.EightBit(foreground: 100)
		] as Color.Wrap
		
		XCTAssert(
			one.isEqual(to: two, equality: Color.Wrap.EqualityType.Set)
		)
		XCTAssert(
			!one.isEqual(to: two, equality: Color.Wrap.EqualityType.Array)
		)
		
		// Defaults to Array Equality
		XCTAssert( !one.isEqual(to: two) )
		
		// `==` operator checks Array Equality
		XCTAssert( !(one == two) )
		XCTAssert( one != two )
		
	}
	
	func testB() {
		let one = [
			Color.Named(foreground: .Green),
			Color.EightBit(background: 200),
			StyleParameter.Encircled
		] as Color.Wrap
		
		let two = [
			Color.EightBit(background: 200),
			StyleParameter.Encircled,
			Color.EightBit(foreground: 100)
		] as Color.Wrap
		
		XCTAssert(one != two)
	}
	
	func testC() {
		let one = [
			Color.Named(foreground: .Green),
			Color.EightBit(background: 200),
			StyleParameter.Encircled
		] as Color.Wrap
		
		let two = [
			Color.EightBit(background: 200),
			StyleParameter.CrossedOut,
			Color.EightBit(foreground: 100)
		] as Color.Wrap
		
		XCTAssert(one != two)
	}

	func testD() {
		let one = Color.Wrap(foreground: .Green)
		
		let two = [
			Color.EightBit(background: 200),
			StyleParameter.CrossedOut,
			Color.EightBit(foreground: 100)
		] as Color.Wrap
		
		XCTAssert(one != two)
	}
	
	func testE() {
		let one: Parameter = Color.Named(foreground: .Yellow)
		let two: Parameter = Color.Named(background: .Yellow)
		// TODO: DOCUMENT: Parameters don't conform to Equatable
		XCTAssert(!(one == two))
		XCTAssert(one != two)
	}

}
