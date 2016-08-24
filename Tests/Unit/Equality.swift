
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
			(StyleParameter.encircled)
		] as Color.Wrap
		
		let two = [
			Color.EightBit(background: 200),
			StyleParameter.encircled,
			Color.EightBit(foreground: 100)
		] as Color.Wrap
		
		XCTAssert(
			one.isEqual(to: two, equality: Color.Wrap.EqualityType.set)
		)
		XCTAssert(
			!one.isEqual(to: two, equality: Color.Wrap.EqualityType.array)
		)
		
		// Defaults to Array Equality
		XCTAssert( !one.isEqual(to: two) )
		
		// `==` operator checks Array Equality
		XCTAssert( !(one == two) )
		XCTAssert( one != two )
		
	}
	
	func testB() {
		let one = [
			Color.Named(foreground: .green),
			Color.EightBit(background: 200),
			StyleParameter.encircled
		] as Color.Wrap
		
		let two = [
			Color.EightBit(background: 200),
			StyleParameter.encircled,
			Color.EightBit(foreground: 100)
		] as Color.Wrap
		
		XCTAssert(one != two)
	}
	
	func testC() {
		let one = [
			Color.Named(foreground: .green),
			Color.EightBit(background: 200),
			StyleParameter.encircled
		] as Color.Wrap
		
		let two = [
			Color.EightBit(background: 200),
			StyleParameter.crossedOut,
			Color.EightBit(foreground: 100)
		] as Color.Wrap
		
		XCTAssert(one != two)
	}

	func testD() {
		let one = Color.Wrap(foreground: .green)
		
		let two = [
			Color.EightBit(background: 200),
			StyleParameter.crossedOut,
			Color.EightBit(foreground: 100)
		] as Color.Wrap
		
		XCTAssert(one != two)
	}
	
	func testE() {
		let one: Parameter = Color.Named(foreground: .yellow)
		let two: Parameter = Color.Named(background: .yellow)
		// TODO: DOCUMENT: Parameters don't conform to Equatable
		XCTAssert(!(one == two))
		XCTAssert(one != two)
	}

}
