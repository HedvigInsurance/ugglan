import Logger

@MainActor
public var graphQlLogger: (any Logging)! = DemoLogger()
