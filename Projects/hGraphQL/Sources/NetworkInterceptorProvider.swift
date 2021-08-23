import Apollo
import Foundation

/// use to override the URLSessionClient used by apollo
public var urlSessionClientProvider: () -> URLSessionClient = {
    URLSessionClient()
}

public class NetworkInterceptorProvider: LegacyInterceptorProvider {
    let token: String
    let acceptLanguageHeader: String
    let userAgent: String

    init(
        store: ApolloStore,
        token: String,
        acceptLanguageHeader: String,
        userAgent: String
    ) {
        self.token = token
        self.acceptLanguageHeader = acceptLanguageHeader
        self.userAgent = userAgent
        super.init(client: urlSessionClientProvider(), store: store)
    }

    override public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(
            HeadersInterceptor(
                token: token,
                acceptLanguageHeader: acceptLanguageHeader,
                userAgent: userAgent
            ),
            at: 0
        )

        return interceptors
    }
}
