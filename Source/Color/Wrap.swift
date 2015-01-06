extension Color {

public struct Wrap: SelectGraphicRenditionWrapType {
	
	public var parameters: [Parameter] = [Parameter]()

	public init(
		parameters: [Parameter] = [Parameter]()
	) {
		self.parameters = parameters
	}
	
	public init(
		style: StyleParameter...
	) {
		self.parameters = style.map { $0 as Parameter }
	}
	
	public init(
		foreground: Color.Named.Color? = nil,
		background: Color.Named.Color? = nil,
		style: StyleParameter...
	) {
		var parameters = [Parameter]()
		
		if let foreground = foreground {
			parameters.append( Color.Named(foreground: foreground) )
		}
		
		if let background = background {
			parameters.append( Color.Named(background: background) )
		}
		
		for parameter in style {
			parameters.append(parameter)
		}
		
		self.parameters = parameters
	}
	
	public init(
		foreground: UInt8? = nil,
		background: UInt8? = nil,
		style: StyleParameter...
	) {
		var parameters = [Parameter]()
		
		if let foreground = foreground {
			parameters.append( Color.EightBit(foreground: foreground) )
		}
		
		if let background = background {
			parameters.append( Color.EightBit(background: background) )
		}
		
		for parameter in style {
			parameters.append(parameter)
		}
		
		self.parameters = parameters
	}
	
	
	public func add(#parameters: StyleParameter...) -> SelectGraphicRenditionWrapType {
		var clone = self
		
		clone.parameters = reduce(
			parameters,
			clone.parameters
		) { (previous, addition) in
				var appendable = previous.filter({ $0.code.enable != addition.code.enable })
				appendable.append(addition)
				return appendable
		}
		
		return clone
	}
	
	public var code: (enable: SelectGraphicRendition, disable: SelectGraphicRendition) {
		
		if self.parameters.isEmpty {
			return ("", "")
		}
		
		var (enables, disables) = self.parameters.reduce(
			(enable: [UInt8](), disable: [UInt8]())
		) { (var previous, value) in
			previous.enable += value.code.enable
			if let disable = value.code.disable {
				previous.disable.append(disable)
			}
			return previous
		}
		
		if disables.isEmpty {
			disables.append(0)
		}
		
		return (
			enable: ECMA48.escape + "[" +
				join(";", enables.map { String($0) } ) +
			"m",
			disable: ECMA48.escape + "[" +
				join(";", disables.map { String($0) } ) +
			"m"
		)
	}
	
	public func wrap(string: String) -> String {
		let (enable, disable) = self.code
		return enable + string + disable
	}
	
	// FIXME: Ridiculous workaround because `Cannot downcast from 'Parameter' to non-@objc protocol type 'ColorType'`
	
	private let foregroundFilter: Parameter -> Bool = {
		switch $0 {
		// FIXME: Ridiculous workaround…
		case let color as Color.Named:
			return color.level == Level.Foreground
		case let color as Color.EightBit:
			return color.level == Level.Foreground
		default:
			return false
		}
	}
	
	private let backgroundFilter: Parameter -> Bool = {
		switch $0 {
		// FIXME: Ridiculous workaround…
		case let color as Color.Named:
			return color.level == Level.Background
		case let color as Color.EightBit:
			return color.level == Level.Background
		default:
			return false
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
	
	public var foreground: Parameter? {
		get {
			return parameters.filter(
				foregroundFilter
			).first
		}
		mutating set(newForeground) {
			var newParameters = [Parameter]()
			if let newForeground = newForeground {
				newParameters.append(newForeground)
			}
			self.parameters = newParameters + parameters.filter {
				!self.foregroundFilter($0)
			}
		}
	}
	
	public var background: Parameter? {
		get {
			return parameters.filter(
				backgroundFilter
			).first
		}
		mutating set(newBackground) {
			var newParameters = [Parameter]()
			if let newBackground = newBackground {
				newParameters.append(newBackground)
			}
			self.parameters = newParameters + parameters.filter {
				!self.backgroundFilter($0)
			}
		}
	}
	
}

}