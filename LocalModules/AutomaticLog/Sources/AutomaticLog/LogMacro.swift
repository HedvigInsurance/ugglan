nonisolated(unsafe) public var loginClosure: @Sendable (String) -> Void = { message in
    print(message)
}

@attached(body)
public macro Log() = #externalMacro(module: "AutomaticLogMacros", type: "AutomaticLog")
