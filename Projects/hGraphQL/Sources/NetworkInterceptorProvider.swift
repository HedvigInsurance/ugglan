@preconcurrency import Apollo
@preconcurrency import ApolloAPI
import Foundation

/// use to override the URLSessionClient used by apollo
@MainActor public var urlSessionClientProvider: () -> URLSessionTaskDelegate? = {
    nil
}
//URLSessionClient
struct NetworkInterceptorProvider: InterceptorProvider {
    nonisolated(unsafe) var dynamicHeaders: () -> [String: String]
    let headers: [String: String]
    init(
        dynamicHeaders: @escaping () -> [String: String],
        headers: [String: String]
    ) {
        self.dynamicHeaders = dynamicHeaders
        self.headers = headers
    }

    func httpInterceptors<Operation>(for operation: Operation) -> [any HTTPInterceptor]
    where Operation: GraphQLOperation {
        var headers = headers
        headers.merge(dynamicHeaders()) { (current, new) in new }
        return [
            HeadersInterceptor(
                headers: headers
            )
        ]
    }
}
