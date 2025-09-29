@preconcurrency import Apollo
@preconcurrency import ApolloAPI
import Foundation

/// use to override the URLSessionClient used by apollo
@MainActor public var urlSessionClientProvider: () -> URLSessionClient = {
    URLSessionClient()
}

@MainActor
class NetworkInterceptorProvider: DefaultInterceptorProvider {
    nonisolated(unsafe) var dynamicHeaders: () -> [String: String]
    let headers: [String: String]
    init(
        store: ApolloStore,
        dynamicHeaders: @escaping () -> [String: String],
        headers: [String: String]
    ) {
        self.dynamicHeaders = dynamicHeaders
        self.headers = headers
        super.init(client: urlSessionClientProvider(), store: store)
    }

    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        var headers = headers
        headers.merge(dynamicHeaders()) { (current, new) in new }
        interceptors.insert(
            HeadersInterceptor(
                headers: headers
            ),
            at: 0
        )

        return interceptors
    }
}
