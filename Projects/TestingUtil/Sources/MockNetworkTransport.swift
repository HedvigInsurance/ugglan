import Apollo
import Foundation

public final class MockNetworkTransport: NetworkTransport {
    enum NetworkError: Error {
        case networkFailure
    }

    private final class MockTask: Cancellable {
        func cancel() {}
    }

    let simulateNetworkFailure: Bool
    let body: JSONObject

    public init(body: JSONObject, simulateNetworkFailure: Bool = false) {
        self.body = body
        self.simulateNetworkFailure = simulateNetworkFailure
    }

    public func send<Operation>(operation: Operation, completionHandler: @escaping (Result<GraphQLResponse<Operation.Data>, Error>) -> Void) -> Cancellable where Operation: GraphQLOperation {
        DispatchQueue.global(qos: .default).async {
            if self.simulateNetworkFailure {
                completionHandler(.failure(NetworkError.networkFailure))
                return
            }

            completionHandler(.success(GraphQLResponse(operation: operation, body: ["data": self.body])))
        }

        return MockTask()
    }
}
