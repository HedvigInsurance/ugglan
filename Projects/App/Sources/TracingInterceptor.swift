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
        let headersWritter = HTTPHeadersWriter()
        let startDate = Date()
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
                
                let endDate = Date()
                
                Global.rum.addResourceMetrics(
                    resourceKey: resourceKey,
                    fetch: (
                        start: startDate,
                        end: endDate
                    ),
                    redirection: nil,
                    dns: nil,
                    connect: nil,
                    ssl: nil,
                    firstByte: nil,
                    download: nil,
                    responseSize: Int64(response?.rawData.count ?? 0)
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
