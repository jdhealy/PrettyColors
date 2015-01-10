
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
		let one = Color.Wrap(parameters: [
			Color.EightBit(foreground: 100),
			Color.EightBit(background: 200),
			StyleParameter.Encircled
		])
		
		let two = Color.Wrap(parameters: [
			Color.EightBit(background: 200),
			StyleParameter.Encircled,
			Color.EightBit(foreground: 100)
		])
		
		XCTAssert(one == two)
	}
	
	func testB() {
		let one = Color.Wrap(parameters: [
			Color.Named(foreground: .Green),
			Color.EightBit(background: 200),
			StyleParameter.Encircled
		])
		
		let two = Color.Wrap(parameters: [
			Color.EightBit(background: 200),
			StyleParameter.Encircled,
			Color.EightBit(foreground: 100)
		])
		
		XCTAssert(one != two)
	}
	
	func testC() {
		let one = Color.Wrap(parameters: [
			Color.Named(foreground: .Green),
			Color.EightBit(background: 200),
			StyleParameter.Encircled
		])
		
		let two = Color.Wrap(parameters: [
			Color.EightBit(background: 200),
			StyleParameter.CrossedOut,
			Color.EightBit(foreground: 100)
		])
		
		XCTAssert(one != two)
	}

	func testD() {
		let one = Color.Wrap(parameters: [
			Color.Named(foreground: .Green),
		])
		
		let two = Color.Wrap(parameters: [
			Color.EightBit(background: 200),
			StyleParameter.CrossedOut,
			Color.EightBit(foreground: 100)
		])
		
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
