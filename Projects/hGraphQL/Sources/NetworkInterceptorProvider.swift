@preconcurrency import Apollo
@preconcurrency import ApolloAPI
import Foundation

/// use to override the URLSessionClient used by apollo
nonisolated(unsafe) public var urlSessionClientProvider: () -> URLSessionClient = {
    URLSessionClient()
}

@MainActor
class NetworkInterceptorProvider: DefaultInterceptorProvider {
    nonisolated(unsafe) var acceptLanguageHeader: () -> String
    let userAgent: String
    let deviceIdentifier: String

    init(
        store: ApolloStore,
        acceptLanguageHeader: @escaping () -> String,
        userAgent: String,
        deviceIdentifier: String
    ) {
        self.acceptLanguageHeader = acceptLanguageHeader
        self.userAgent = userAgent
        self.deviceIdentifier = deviceIdentifier
        super.init(client: urlSessionClientProvider(), store: store)
    }

    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(
            HeadersInterceptor(
                acceptLanguageHeader: acceptLanguageHeader(),
                userAgent: userAgent,
                deviceIdentifier: deviceIdentifier
            ),
            at: 0
        )

        return interceptors
    }
}
