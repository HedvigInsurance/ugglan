nonisolated(unsafe) public var loginClosure: @Sendable (String) -> Void = { message in
    print(message)
}

public struct LogOptions: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let output = LogOptions(rawValue: 1 << 0)
    public static let error = LogOptions(rawValue: 1 << 1)

    public static let all: LogOptions = [.output, .error]
}

public protocol MaskedFieldsProviding {
    static var maskedLogFields: Set<String> { get }
}

extension MaskedFieldsProviding {
    /// Instance-side access, so `logDescription(_:)` can read the set off an existential.
    var maskedLogFieldsForLogging: Set<String> { Self.maskedLogFields }
}

public protocol MaskedValue {
    var maskedDescription: String { get }
}

public func logDescription(_ value: Any) -> String {
    _describe(value)
}

public func maskedLogDescription(_ value: Any) -> String {
    _mask(value)
}

private func _mask(_ value: Any) -> String {
    let mirror = Mirror(reflecting: value)
    if mirror.displayStyle == .optional {
        if let child = mirror.children.first {
            return _mask(child.value)
        }
        return "nil"
    }
    let length = String(describing: value).count
    return String(repeating: "*", count: length)
}

private func _describe(_ value: Any) -> String {
    // Checked here rather than at each call site, so a type that masks itself keeps masking
    // wherever it sits: a property, an array element, a dictionary value.
    if let masked = value as? MaskedValue {
        return masked.maskedDescription
    }

    let mirror = Mirror(reflecting: value)

    if mirror.children.isEmpty {
        return String(describing: value)
    }

    switch mirror.displayStyle {
    case .optional:
        if let child = mirror.children.first {
            return _describe(child.value)
        }
        return "nil"

    case .collection, .set:
        let parts = mirror.children.map { _describe($0.value) }
        return "[\(parts.joined(separator: ", "))]"

    case .dictionary:
        let parts = mirror.children.map { child -> String in
            let pairChildren = Array(Mirror(reflecting: child.value).children)
            if pairChildren.count == 2 {
                return "\(String(describing: pairChildren[0].value)): \(_describe(pairChildren[1].value))"
            }
            return _describe(child.value)
        }
        return "[\(parts.joined(separator: ", "))]"

    default:
        let maskedFields = (value as? any MaskedFieldsProviding)?.maskedLogFieldsForLogging ?? []
        var parts: [String] = []
        for child in mirror.children {
            guard let label = child.label else {
                parts.append(_describe(child.value))
                continue
            }
            // @Published and property wrappers store under a leading underscore.
            let name = label.hasPrefix("_") ? String(label.dropFirst()) : label
            if maskedFields.contains(name) {
                parts.append("\(name): \(_mask(child.value))")
            } else {
                parts.append("\(name): \(_describe(child.value))")
            }
        }
        return "\(type(of: value))(\(parts.joined(separator: ", ")))"
    }
}

@attached(peer)
public macro Masked() = #externalMacro(module: "AutomaticLogMacros", type: "MaskedMacro")

@attached(extension, conformances: MaskedFieldsProviding, names: named(maskedLogFields))
public macro Loggable() = #externalMacro(module: "AutomaticLogMacros", type: "LoggableMacro")

@attached(body)
public macro Log(_ options: LogOptions = .all, masked: [String] = []) =
    #externalMacro(module: "AutomaticLogMacros", type: "AutomaticLog")
