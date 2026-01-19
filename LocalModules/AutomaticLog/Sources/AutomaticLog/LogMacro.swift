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

@attached(body)
public macro Log(_ options: LogOptions = .all) = #externalMacro(module: "AutomaticLogMacros", type: "AutomaticLog")
