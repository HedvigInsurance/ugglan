import Apollo
import Foundation

/// use to override the URLSessionClient used by apollo
public var urlSessionClientProvider: () -> URLSessionClient = {
    URLSessionClient()
}

public class NetworkInterceptorProvider: DefaultInterceptorProvider {
    let token: String
    let acceptLanguageHeader: String
    let userAgent: String
    let deviceIdentifier: String

    init(
        store: ApolloStore,
        token: String,
        acceptLanguageHeader: String,
        userAgent: String,
        deviceIdentifier: String
    ) {
        self.token = token
        self.acceptLanguageHeader = acceptLanguageHeader
        self.userAgent = userAgent
        self.deviceIdentifier = deviceIdentifier
        super.init(client: urlSessionClientProvider(), store: store)
    }

    override public func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(
            HeadersInterceptor(
                token: token,
                acceptLanguageHeader: acceptLanguageHeader,
                userAgent: userAgent,
                deviceIdentifier: deviceIdentifier
            ),
            at: 0
        )

        return interceptors
    }
}
