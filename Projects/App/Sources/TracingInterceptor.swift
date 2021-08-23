import Apollo
import Datadog
import Foundation

public class TracingInterceptor: ApolloInterceptor {
    public func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        let resourceKey = "\(request.operation.operationType) \(request.operation.operationName)"
        
        if let request = try? request.toURLRequest() {
            Global.rum.startResourceLoading(
                resourceKey: resourceKey,
                request: request
            )
        }
                
        let headersWritter = HTTPHeadersWriter()
        let span = Global.sharedTracer.startSpan(
            operationName: resourceKey
        )
        Global.sharedTracer.inject(spanContext: span.context, writer: headersWritter)

        headersWritter.tracePropagationHTTPHeaders.forEach { key, value in request.addHeader(name: key, value: value) }

        chain.proceedAsync(
            request: request,
            response: response,
            completion: { result in
                completion(result)
                Global.rum.stopResourceLoading(
                    resourceKey: resourceKey,
                    statusCode: 200,
                    kind: .fetch
                )

                switch result {
                case let .failure(error):
                    span.setError(error)
                default:
                    break
                }

                span.finish()
            }
        )
    }
}
