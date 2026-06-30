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

public let redactedFieldNames: Set<String> = [
    "ssn",
    "personalnumber",
    "otpstate",
    "code",
    "refreshtoken",
    "token",
    "email",
    "phone",
    "eurobonus",
    "message",
    "files",
]

public func redactedDescription(_ value: Any, name: String? = nil) -> String {
    if let name, redactedFieldNames.contains(name.lowercased()) {
        return _mask(value)
    }
    return _redact(value)
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

private func _redact(_ value: Any) -> String {
    let mirror = Mirror(reflecting: value)

    if mirror.children.isEmpty {
        return String(describing: value)
    }

    switch mirror.displayStyle {
    case .optional:
        if let child = mirror.children.first {
            return _redact(child.value)
        }
        return "nil"

    case .collection, .set:
        let parts = mirror.children.map { _redact($0.value) }
        return "[\(parts.joined(separator: ", "))]"

    case .dictionary:
        let parts = mirror.children.map { child -> String in
            let pairChildren = Array(Mirror(reflecting: child.value).children)
            if pairChildren.count == 2 {
                return "\(String(describing: pairChildren[0].value)): \(_redact(pairChildren[1].value))"
            }
            return _redact(child.value)
        }
        return "[\(parts.joined(separator: ", "))]"

    default:
        var parts: [String] = []
        for child in mirror.children {
            if let label = child.label {
                if redactedFieldNames.contains(label.lowercased()) {
                    parts.append("\(label): \(_mask(child.value))")
                } else {
                    parts.append("\(label): \(_redact(child.value))")
                }
            } else {
                parts.append(_redact(child.value))
            }
        }
        return "\(type(of: value))(\(parts.joined(separator: ", ")))"
    }
}

@attached(body)
public macro Log(_ options: LogOptions = .all) = #externalMacro(module: "AutomaticLogMacros", type: "AutomaticLog")
