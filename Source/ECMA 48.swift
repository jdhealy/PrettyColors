
public struct ECMA48 {
	/// “ESC is used for code extension purposes. It causes the meanings of a limited 
	/// number of bit combinations following it in the data stream to be changed.”
	static let escape = "\u{001B}"
	/// “used as the first character of a control sequence”
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
