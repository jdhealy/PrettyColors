/* begin extension of color */ extension Color {

//------------------------------------------------------------------------------
// MARK: - Wrap
//------------------------------------------------------------------------------

public struct Wrap: SelectGraphicRenditionWrapType {

	public typealias Element = Parameter
	public typealias UnderlyingCollection = [Element]
	
	public var parameters = UnderlyingCollection()

	//------------------------------------------------------------------------------
	// MARK: - Initializers
	//------------------------------------------------------------------------------

	public init<S: SequenceType where S.Generator.Element == Element>(parameters: S) {
		self.parameters = [] as UnderlyingCollection + parameters
	}
	
	// This might be impossible to call…
	// but, it needs to be defined for protocol conformance.
	public init() {
		self.init(
			parameters: [] as UnderlyingCollection
		)
	}
	
	public init(arrayLiteral parameters: Element...) {
		self.init(parameters: parameters)
	}

	public init(
		foreground: Color.Named.Color? = nil,
		background: Color.Named.Color? = nil,
		style: StyleParameter...
	) {
		var parameters: [Parameter] = []
		
		if let foreground = foreground {
			parameters.append( Color.Named(foreground: foreground) )
		}
		
		if let background = background {
			parameters.append( Color.Named(background: background) )
		}
		
		for parameter in style {
			parameters.append(parameter)
		}
		
		self.init(parameters: parameters)
	}
	
	public init(
		foreground: UInt8? = nil,
		background: UInt8? = nil,
		style: StyleParameter...
	) {
		var parameters: [Parameter] = []
		
		if let foreground = foreground {
			parameters.append( Color.EightBit(foreground: foreground) )
		}
		
		if let background = background {
			parameters.append( Color.EightBit(background: background) )
		}
		
		for parameter in style {
			parameters.append(parameter)
		}
		
		self.init(parameters: parameters)
	}
	
	public init(styles: StyleParameter...) {
		var parameters: [Parameter] = []
		
		for parameter in styles {
			parameters.append(parameter)
		}
		
		self.init(parameters: parameters)
	}
	
	//------------------------------------------------------------------------------
	// MARK: - SelectGraphicRenditionWrap
	//------------------------------------------------------------------------------

	/// A SelectGraphicRendition code in two parts: enable and disable.
	public var code: (enable: SelectGraphicRendition, disable: SelectGraphicRendition) {
		
		if self.parameters.isEmpty {
			return ("", "")
		}

		let disableAll = [StyleParameter.Reset.defaultRendition]
		
		var (enables, disables) = self.parameters.reduce(
			(enable: [UInt8](), disable: [UInt8]())
		) { (var previous, value) in
			previous.enable += value.code.enable
			if previous.disable != disableAll {
				if let disable = value.code.disable {
					previous.disable.append(disable)
				} else {
					previous.disable = disableAll
				}
			}
			return previous
		}
		
		return (
			enable: ECMA48.controlSequenceIntroducer +
				join(";", enables.map { String($0) } ) +
				"m",
			disable: ECMA48.controlSequenceIntroducer +
				join(";", disables.map { String($0) } ) +
				"m"
		)
	}
	
	/// Wraps the enable and disable SelectGraphicRendition codes around a string.
	public func wrap(string: String) -> String {
		let (enable, disable) = self.code
		return enable + string + disable
	}
	
	//------------------------------------------------------------------------------
	// MARK: - Foreground/Background Helpers
	//------------------------------------------------------------------------------
	// FIXME: Ridiculous workaround “downcast” issue by using `switch`…
	// `Cannot downcast from 'Parameter' to non-@objc protocol type 'ColorType'`
	
	struct Filters {

		private static func level(level: Level) -> (Parameter -> Bool) {
			return {
				switch $0 {
				// FIXME: Ridiculous workaround…
				case let color as Color.Named:
					return color.level == level
				case let color as Color.EightBit:
					return color.level == level
				default:
					return false
				}
			}
		}
	
	}
	
	public var foreground: Parameter? {
		get {
			return parameters.filter(
				Filters.level(.Foreground)
			).first
		}
		mutating set(newForeground) {
			var newParameters = [Parameter]()
			if let newForeground = newForeground {
				newParameters.append(newForeground)
			}
			self.parameters = newParameters + parameters.filter {
				!Filters.level(.Foreground)($0)
			}
		}
	}
	
	public var background: Parameter? {
		get {
			return parameters.filter(
				Filters.level(.Background)
			).first
		}
		mutating set(newBackground) {
			var newParameters = [Parameter]()
			if let newBackground = newBackground {
				newParameters.append(newBackground)
			}
			self.parameters = newParameters + parameters.filter {
				!Filters.level(.Background)($0)
			}
		}
	}

	
	public mutating func foreground(transform: ColorType -> ColorType) -> Bool {
		
		var transformed = Bool?()
		
		self.parameters = self.parameters.map {
			(parameter: Parameter) -> Parameter in
			
			switch parameter {
			// FIXME: Ridiculous workaround…
			case let color as Color.Named:
				transformed = true
				if !(color.level == Level.Foreground) { return parameter }
				return transform(color as ColorType)
			case let color as Color.EightBit:
				if !(color.level == Level.Foreground) { return parameter }
				transformed = true
				return transform(color as ColorType)
			default:
				return parameter
			}
		}
		
		return transformed ?? false
	}
	
	public mutating func background(transform: ColorType -> ColorType) -> Bool {
		
		var transformed = Bool?()
		
		self.parameters = self.parameters.map {
			(parameter: Parameter) -> Parameter in
			
			switch parameter {
			// FIXME: Ridiculous workaround…
			case let color as Color.Named:
				transformed = true
				if !(color.level == Level.Background) { return parameter }
				return transform(color as ColorType)
			case let color as Color.EightBit:
				if !(color.level == Level.Foreground) { return parameter }
				transformed = true
				return transform(color as ColorType)
			default:
				return parameter
			}
		}
		
		return transformed ?? false
	}

	//------------------------------------------------------------------------------
	// MARK: - Big Three
	//------------------------------------------------------------------------------
	
	public func map<T>(transform: Element -> T) -> [T] {
		return Swift.map(self, transform)
	}

	public func filter(includeElement: Element -> Bool) -> Color.Wrap {
		return Color.Wrap(parameters: Swift.filter(self, includeElement))
	}
	
	public func reduce<U>(initial: U, combine: (U, Element) -> U) -> U {
		return Swift.reduce(self, initial, combine)
	}
	
}

/* end extension of color */ }

//------------------------------------------------------------------------------
// MARK: - Wrap: SequenceType
//------------------------------------------------------------------------------

extension Color.Wrap: SequenceType {
	public typealias Generator = GeneratorOf<Element>
	public func generate() -> Generator {
		var generator = parameters.generate()
		return GeneratorOf { return generator.next() }
	}
}

//------------------------------------------------------------------------------
// MARK: - Wrap: CollectionType
//------------------------------------------------------------------------------

extension Color.Wrap: MutableCollectionType {
	public typealias Index = UnderlyingCollection.Index
	public var startIndex: Index { return parameters.startIndex }
	public var endIndex: Index { return parameters.endIndex }
	
	public subscript(position:Index) -> Generator.Element {
		get { return parameters[position] }
		set { parameters[position] = newValue }
	}
}

//------------------------------------------------------------------------------
// MARK: - Wrap: ExtensibleCollectionType
//------------------------------------------------------------------------------

extension Color.Wrap: ExtensibleCollectionType {
	public mutating func reserveCapacity(n: Index.Distance) {
		parameters.reserveCapacity(n)
	}

	public mutating func append(newElement: Element) {
		parameters.append(newElement)
	}
	
	public mutating func append(#style: StyleParameter...) {
		for parameter in style {
			parameters.append(parameter)
		}
	}
	
	public mutating func extend <S: SequenceType where S.Generator.Element == Element> (sequence: S) {
		parameters.extend(sequence)
	}
}

//------------------------------------------------------------------------------
// MARK: - Wrap: ArrayLiteralConvertible
//------------------------------------------------------------------------------

extension Color.Wrap: ArrayLiteralConvertible {}

//------------------------------------------------------------------------------
// MARK: - Wrap: Equatable
//------------------------------------------------------------------------------

extension Color.Wrap: Equatable {
	
	public enum EqualityType {
		case Array
		case Set
	}
	
	private func setEqualilty(a: Color.Wrap, _ b: Color.Wrap) -> Bool {
		if a.parameters.count != b.parameters.count {
			return false
		} else {
			let stringify: (Parameter) -> String = {
				join( "-", $0.code.enable.map { String($0) } )
			}
			
			let sort: (Parameter, Parameter) -> Bool = {
				(one, two) in
				return stringify(one) > stringify (two)
			}
			
			var x = a.parameters.sorted(sort)
			var y = b.parameters.sorted(sort)
			
			return x.reduce((equal: true, index: y.startIndex)) {
				(previous, value) in
				return (
					previous.equal && value == y[previous.index],
					previous.index + 1
				)
			}.equal
		}
	}
	
	public func isEqual(to other: Color.Wrap, equality: Color.Wrap.EqualityType = .Array) -> Bool {
		switch equality {
		case .Array:
			return
				self.parameters.count == other.parameters.count &&
				self.code.enable == other.code.enable
		case .Set:
			return setEqualilty(self, other)
		}
	}

}

public func == (a: Color.Wrap, b: Color.Wrap) -> Bool {
	return a.isEqual(to: b, equality: .Array)
}
