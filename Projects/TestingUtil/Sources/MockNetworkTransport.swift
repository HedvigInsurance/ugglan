import Apollo
import Foundation
import hCore

var mockURL: URL {
    URL(string: "https://www.hedvig.com")!
}

public enum MockError: Error { case failed }

public class MockNetworkFetchInterceptor: ApolloInterceptor, Cancellable {
    public init() {}
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
      if let handler = handlers.compactMapValues({ value in
        value as? (_ operation: Operation) throws -> Operation.Data
      }).first?.value {
        do {
            let dataEntry = try handler(request.operation)
            
            let response = HTTPResponse<Operation>(
              response: .init(url: mockURL, statusCode: 200, httpVersion: "1.1", headerFields: [:])!,
              rawData: try! JSONSerialization.data(withJSONObject: [
                  "data": dataEntry.jsonObject
              ].jsonObject, options: []),
              parsedResponse: nil
            )
            
            chain.proceedAsync(request: request,
                               response: response,
                               completion: completion)
        } catch {
            chain.handleErrorAsync(error,
                                   request: request,
                                   response: response,
                                   completion: completion)
        }
      }
    
  }
    
    private final class MockTask: Cancellable { func cancel() {} }

    var handlers: [AnyHashable: Any] = [:]

    public func handle<Operation: GraphQLOperation>(_ operationType: Operation.Type, requestHandler: @escaping (_ operation: Operation) throws -> Operation.Data) {
        handlers[ObjectIdentifier(operationType)] = requestHandler
    }
  
  public func cancel() {}
}

open class MockInterceptorProvider: InterceptorProvider {
  public let store: ApolloStore
    private let mockNetworkFetchInterceptor = MockNetworkFetchInterceptor()
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - store: The `ApolloStore` to use when reading from or writing to the cache. Make sure you pass the same store to the `ApolloClient` instance you're planning to use.
  public init(store: ApolloStore = ApolloStore()) {
    self.store = store
  }

    public func handle<Operation: GraphQLOperation>(_ operationType: Operation.Type, requestHandler: @escaping (_ operation: Operation) throws -> Operation.Data) {
        mockNetworkFetchInterceptor.handle(operationType, requestHandler: requestHandler)
    }
  
  open func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
      return [
        MaxRetryInterceptor(),
        LegacyCacheReadInterceptor(store: self.store),
        mockNetworkFetchInterceptor,
        ResponseCodeInterceptor(),
        LegacyParsingInterceptor(cacheKeyForObject: self.store.cacheKeyForObject),
        AutomaticPersistedQueryInterceptor(),
        LegacyCacheWriteInterceptor(store: self.store),
    ]
  }
  
  open func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor? {
    return nil
  }
}

public final class MockRequestChainNetworkTransport: RequestChainNetworkTransport {
    public init(interceptorProvider: MockInterceptorProvider) {
        super.init(interceptorProvider: interceptorProvider, endpointURL: mockURL)
    }
}

extension ApolloClient {
    public static func createMock(mockInterceptorProvider: MockInterceptorProvider) {
        let client = ApolloClient(
            networkTransport: MockRequestChainNetworkTransport(interceptorProvider: mockInterceptorProvider),
            store: mockInterceptorProvider.store
        )
        
        Dependencies.shared.add(module: Module { () -> ApolloClient in
            client
        })
        
        Dependencies.shared.add(module: Module { () -> ApolloStore in
            mockInterceptorProvider.store
        })
    }
}


public final class MockNetworkTransport: NetworkTransport {
	public func send<Operation>(
		operation _: Operation,
		cachePolicy _: CachePolicy,
		contextIdentifier _: UUID?,
		callbackQueue _: DispatchQueue,
		completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
	) -> Cancellable where Operation: GraphQLOperation {
		DispatchQueue.global(qos: .default)
			.async {
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

	public init(
		body: JSONObject,
		simulateNetworkFailure: Bool = false
	) {
		self.body = body
		self.simulateNetworkFailure = simulateNetworkFailure
	}
}
