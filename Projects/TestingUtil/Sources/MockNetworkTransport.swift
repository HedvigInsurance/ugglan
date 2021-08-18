import Apollo
import ApolloWebSocket
import Flow
import Foundation
import hCore

var mockURL: URL {
    URL(string: "https://www.hedvig.com")!
}

public enum MockError: Error { case failed }

public class MockNetworkFetchInterceptor: ApolloInterceptor, Cancellable {
    let handlers: GraphQLMockHandlers

    internal init(
        handlers: GraphQLMockHandlers
    ) {
        self.handlers = handlers
    }

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        duration: TimeInterval,
        data: Operation.Data,
        completion: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        let mainQueue = DispatchQueue.main
        let deadline = DispatchTime.now() + duration
        mainQueue.asyncAfter(deadline: deadline) {
            let httpURLResponse = HTTPURLResponse()

            let response = HTTPResponse<Operation>(
                response: httpURLResponse,
                rawData: try! JSONSerialization.data(
                    withJSONObject: [
                        "data": data.jsonObject
                    ]
                    .jsonObject,
                    options: []
                ),
                parsedResponse: nil
            )

            chain.proceedAsync(
                request: request,
                response: response,
                completion: completion
            )
        }
    }

    public func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        if let handler = handlers[ObjectIdentifier(Operation.self)] as? QueryMock<Operation> {
            do {
                let data = try handler.handler(request.operation)

                interceptAsync(
                    chain: chain,
                    request: request,
                    response: response,
                    duration: handler.duration,
                    data: data,
                    completion: completion
                )
            } catch {
                chain.handleErrorAsync(
                    error,
                    request: request,
                    response: response,
                    completion: completion
                )
            }
        } else if let handler = handlers[ObjectIdentifier(Operation.self)] as? MutationMock<Operation> {
            do {
                let data = try handler.handler(request.operation)

                interceptAsync(
                    chain: chain,
                    request: request,
                    response: response,
                    duration: handler.duration,
                    data: data,
                    completion: completion
                )
            } catch {
                chain.handleErrorAsync(
                    error,
                    request: request,
                    response: response,
                    completion: completion
                )
            }
        }
    }

    public func cancel() {}
}

open class MockInterceptorProvider: InterceptorProvider {
    public let store: ApolloStore
    let mockNetworkFetchInterceptor: MockNetworkFetchInterceptor

    /// Designated initializer
    ///
    /// - Parameters:
    ///   - store: The `ApolloStore` to use when reading from or writing to the cache. Make sure you pass the same store to the `ApolloClient` instance you're planning to use.
    public init(
        store: ApolloStore = ApolloStore(),
        handlers: GraphQLMockHandlers
    ) {
        self.store = store
        self.mockNetworkFetchInterceptor = MockNetworkFetchInterceptor(handlers: handlers)
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

    open func additionalErrorInterceptor<Operation: GraphQLOperation>(
        for operation: Operation
    ) -> ApolloErrorInterceptor? {
        return nil
    }
}

public final class MockRequestChainNetworkTransport: RequestChainNetworkTransport {
    public init(
        interceptorProvider: MockInterceptorProvider
    ) {
        super.init(interceptorProvider: interceptorProvider, endpointURL: mockURL)
    }
}

public class MockWebSocketNetworkTransport: NetworkTransport {
    let handlers: GraphQLMockHandlers

    internal init(
        handlers: GraphQLMockHandlers
    ) {
        self.handlers = handlers
    }

    let bag = DisposeBag()

    private final class MockTask: Cancellable { func cancel() {} }

    public func send<Operation>(
        operation: Operation,
        cachePolicy: CachePolicy,
        contextIdentifier: UUID?,
        callbackQueue: DispatchQueue,
        completionHandler: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) -> Cancellable where Operation: GraphQLOperation {
        if let handler = handlers[ObjectIdentifier(Operation.self)] as? SubscriptionMock<Operation> {
            let mainQueue = DispatchQueue.main
            let deadline = DispatchTime.now() + handler.duration
            mainQueue.asyncAfter(deadline: deadline) {
                do {
                    let signal = try handler.handler(operation)

                    self.bag += signal.onValue { dataEntry in
                        let response = GraphQLResponse(
                            operation: operation,
                            body: [
                                "data": dataEntry.jsonObject
                            ]
                            .jsonObject
                        )

                        if let result = try? response.parseResultFast() {
                            completionHandler(.success(result))
                        } else {
                            completionHandler(.failure(MockError.failed))
                        }
                    }
                } catch {
                    completionHandler(.failure(MockError.failed))
                }
            }
        }

        return MockTask()
    }
}

extension ApolloClient {
    public static func createMock(@GraphQLMockBuilder _ builder: () -> GraphQLMock) {
        let store = ApolloStore()
        let mock = builder()

        let mockInterceptorProvider = MockInterceptorProvider(store: store, handlers: mock.handlers)

        let networkTransport = SplitNetworkTransport(
            uploadingNetworkTransport: MockRequestChainNetworkTransport(
                interceptorProvider: mockInterceptorProvider
            ),
            webSocketNetworkTransport: MockWebSocketNetworkTransport(
                handlers: mock.handlers
            )
        )

        let client = ApolloClient(
            networkTransport: networkTransport,
            store: mockInterceptorProvider.store
        )

        Dependencies.shared.add(
            module: Module { () -> ApolloClient in
                client
            }
        )

        Dependencies.shared.add(
            module: Module { () -> ApolloStore in
                store
            }
        )
    }
}

public final class MockNetworkTransport: NetworkTransport {
    public func send<Operation>(
        operation _: Operation,
        cachePolicy _: CachePolicy,
        contextIdentifier _: UUID?,
        callbackQueue _: DispatchQueue,
        completionHandler: @escaping (Swift.Result<GraphQLResult<Operation.Data>, Error>) -> Void
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
