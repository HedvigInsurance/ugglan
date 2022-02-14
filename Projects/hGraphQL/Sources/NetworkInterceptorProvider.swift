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
        
        //interceptors.append(JSONResponseParsingInterceptor())
        interceptors.append(VersionErrorInterceptor())

        return interceptors
    }
}

extension ApolloClient {
    public static func 
}

class VersionErrorInterceptor: ApolloInterceptor {
    enum VersionError: Error {
        case notYetReceived
    }
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
            defer {
                chain.proceedAsync(request: request, response: response, completion: completion)
            }
            guard let res = response?.parsedResponse else {
                chain.handleErrorAsync(VersionError.notYetReceived, request: request, response: response, completion: completion)
                return
            }
            
            if let versionError = VersionErrorHandler().getVersionError(from: res.errors) {
                chain.handleErrorAsync(versionError, request: request, response: response, completion: completion)
                print("BOOMERROR:", versionError)
            }
            
    }
}
