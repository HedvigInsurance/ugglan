import Apollo
import Foundation

/// use to override the URLSessionClient used by apollo
public var urlSessionClientProvider: () -> URLSessionClient = {
    URLSessionClient()
}

public class NetworkInterceptorProvider: DefaultInterceptorProvider {
    let acceptLanguageHeader: String
    let userAgent: String
    let deviceIdentifier: String

    init(
        store: ApolloStore,
        acceptLanguageHeader: String,
        userAgent: String,
        deviceIdentifier: String
    ) {
        self.acceptLanguageHeader = acceptLanguageHeader
        self.userAgent = userAgent
        self.deviceIdentifier = deviceIdentifier
        super.init(client: urlSessionClientProvider(), store: store)
    }

    override public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(
            HeadersInterceptor(
                acceptLanguageHeader: acceptLanguageHeader,
                userAgent: userAgent,
                deviceIdentifier: deviceIdentifier
            ),
            at: 0
        )

        return interceptors
    }
}
