//
//  ApolloMockNetworkTransport.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
import Dispatch
import Foundation

public final class MockNetworkTransport: NetworkTransport, UploadingNetworkTransport {
    public func upload<Operation>(operation: Operation, files: [GraphQLFile], completionHandler: @escaping (Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable where Operation : GraphQLOperation {
        DispatchQueue.global(qos: .default).async {
            completionHandler(Result {
                GraphQLResponse(operation: operation, body: self.body)
            })
        }
        return MockTask()
    }
    
    public func send<Operation>(operation: Operation, completionHandler: @escaping (Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable where Operation : GraphQLOperation {
        
        DispatchQueue.global(qos: .default).async {
            completionHandler(Result {
                GraphQLResponse(operation: operation, body: self.body)
            })
        }
        return MockTask()
    }
    
    let body: JSONObject

    public init(body: JSONObject) {
        self.body = body
    }

    public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
        DispatchQueue.global(qos: .default).async {
            completionHandler(GraphQLResponse(operation: operation, body: self.body), nil)
        }
        return MockTask()
    }
}

private final class MockTask: Cancellable {
    func cancel() {}
}
