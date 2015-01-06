
// TODO: Make Color.Wrap, Color.Named, Color.EightBit

public struct ECMA48 {
	static let escape = "\u{001B}"
	static let controlSequenceIntroducer = escape + "["
}

public typealias SelectGraphicRendition = String

public protocol SelectGraphicRenditionWrapType {
	
	/// A SelectGraphicRendition code in two parts: enable and disable.
	var code: (enable: SelectGraphicRendition, disable: SelectGraphicRendition) { get }
	
	/// Wraps a string in the SelectGraphicRendition code.
	func wrap(string: String) -> String
	
	// This would be better typed as a Set, but
	// there's no Set in the Swift stdlib yet…
	var parameters: [Parameter] { get set }
	
	func add(#parameters: StyleParameter...) -> SelectGraphicRenditionWrapType
	
}

public protocol Parameter {
	var code: (enable: [UInt8], disable: UInt8?) { get }
}
