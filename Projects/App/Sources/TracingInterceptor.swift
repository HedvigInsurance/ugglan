//
//  TracingInterceptor.swift
//  TracingInterceptor
//
//  Created by Sam Pettersson on 2021-08-20.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Apollo
import Datadog

public class TracingInterceptor: ApolloInterceptor {
    public func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        let headersWritter = HTTPHeadersWriter()
        let span = Global.sharedTracer.startSpan(operationName: "\(request.operation.operationType) \(request.operation.operationName)")
        Global.sharedTracer.inject(spanContext: span.context, writer: headersWritter)

        headersWritter.tracePropagationHTTPHeaders.forEach { key, value in request.addHeader(name: key, value: value) }

        chain.proceedAsync(
            request: request,
            response: response,
            completion: { result in
                completion(result)
                
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
