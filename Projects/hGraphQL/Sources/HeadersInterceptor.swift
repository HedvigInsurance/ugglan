import Apollo
import Foundation

public class HeadersInterceptor: ApolloInterceptor {
    let token: String
    let acceptLanguageHeader: String
    let userAgent: String

    init(
        token: String,
        acceptLanguageHeader: String,
        userAgent: String
    ) {
        self.token = token
        self.acceptLanguageHeader = acceptLanguageHeader
        self.userAgent = userAgent
    }

    public static var getTracing: () -> (headers: [String: String], onCompletion: () -> Void) = { (headers: [:], onCompletion: {}) }

    public func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        let tracing = Self.getTracing()
        
        let httpAdditionalHeaders = [
            "Authorization": token, "Accept-Language": acceptLanguageHeader, "User-Agent": userAgent,
        ]
        .merging(
            tracing.headers,
            uniquingKeysWith: { lhs, _ in lhs }
        )

        httpAdditionalHeaders.forEach { key, value in request.addHeader(name: key, value: value) }

        chain.proceedAsync(request: request, response: response, completion: { result in
            completion(result)
            tracing.onCompletion()
        })
    }
}
