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

public protocol SensitiveFieldsProviding {
    static var sensitiveLogFields: Set<String> { get }
}

extension SensitiveFieldsProviding {
    /// Instance-side access, so `logDescription(_:)` can read the set off an existential.
    var sensitiveLogFieldsForLogging: Set<String> { Self.sensitiveLogFields }
}

public protocol SensitiveValue {
    var maskedDescription: String { get }
}

public func logDescription(_ value: Any) -> String {
    if let sensitive = value as? SensitiveValue {
        return sensitive.maskedDescription
    }
    return _describe(value)
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
        let sensitiveFields = (value as? any SensitiveFieldsProviding)?.sensitiveLogFieldsForLogging ?? []
        var parts: [String] = []
        for child in mirror.children {
            guard let label = child.label else {
                parts.append(_describe(child.value))
                continue
            }
            // @Published and property wrappers store under a leading underscore.
            let name = label.hasPrefix("_") ? String(label.dropFirst()) : label
            if sensitiveFields.contains(name) {
                parts.append("\(name): \(_mask(child.value))")
            } else if let sensitive = child.value as? SensitiveValue {
                parts.append("\(name): \(sensitive.maskedDescription)")
            } else {
                parts.append("\(name): \(_describe(child.value))")
            }
        }
        return "\(type(of: value))(\(parts.joined(separator: ", ")))"
    }
}

@attached(peer)
public macro Sensitive() = #externalMacro(module: "AutomaticLogMacros", type: "SensitiveMacro")

@attached(extension, conformances: SensitiveFieldsProviding, names: named(sensitiveLogFields))
public macro Loggable() = #externalMacro(module: "AutomaticLogMacros", type: "LoggableMacro")

@attached(body)
public macro Log(_ options: LogOptions = .all, sensitive: [String] = []) =
    #externalMacro(module: "AutomaticLogMacros", type: "AutomaticLog")
