import Apollo
import Foundation

public final class MockNetworkTransport: NetworkTransport {
	public func send<Operation>(
		operation _: Operation,
		cachePolicy _: CachePolicy,
		contextIdentifier _: UUID?,
		callbackQueue _: DispatchQueue,
		completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
	) -> Cancellable where Operation: GraphQLOperation {
		DispatchQueue.global(qos: .default).async {
			if self.simulateNetworkFailure {
				completionHandler(.failure(NetworkError.networkFailure))
				return
			}
		}

		if let data = try? Operation.Data(jsonObject: body) {
			completionHandler(
				.success(
					.init(
						data: data,
						extensions: nil,
						errors: nil,
						source: .server,
						dependentKeys: nil
					)
				)
			)
		}

		return MockTask()
	}

	enum NetworkError: Error { case networkFailure }

	private final class MockTask: Cancellable { func cancel() {} }

	let simulateNetworkFailure: Bool
	let body: JSONObject

	public init(body: JSONObject, simulateNetworkFailure: Bool = false) {
		self.body = body
		self.simulateNetworkFailure = simulateNetworkFailure
	}
}
