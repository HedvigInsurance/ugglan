import Apollo
import Foundation
import Logger
import TestDependencies
import Testing

@testable import hGraphQL

@Suite(.serialized)
@MainActor
final class GraphQLExceptionLoggingTests {
    // Serialized because every test swaps the process-wide graphQlLogger.
    private weak var client: ApolloClient?
    private var originalLogger: (any Logging)!
    private let logger = LoggerSpy()

    init() {
        originalLogger = graphQlLogger
        graphQlLogger = logger
    }

    // Bodies are scoped in do/recordingErrors so the client is released before the check.
    private func restoreLoggerAndExpectClientReleased() async {
        graphQlLogger = originalLogger
        originalLogger = nil
        try? await Task.sleep(nanoseconds: 100)
        #expect(client == nil, "the apollo client must not outlive the test that created it")
    }

    private func makeClient(_ outcome: StubNetworkTransport.Outcome) -> ApolloClient {
        let client = ApolloClient(networkTransport: StubNetworkTransport(outcome), store: ApolloStore())
        self.client = client
        return client
    }

    // The return types pin the hGraphQL overloads, which are the ones that log.
    private func fetchCurrentMemberId(
        with client: ApolloClient
    ) async throws -> OctopusGraphQL.CurrentMemberIdQuery.Data {
        try await client.fetch(query: OctopusGraphQL.CurrentMemberIdQuery())
    }

    private func requestMemberDeletion(
        with client: ApolloClient
    ) async throws -> OctopusGraphQL.MemberDeletionRequestMutation.Data? {
        try await client.mutation(mutation: OctopusGraphQL.MemberDeletionRequestMutation())
    }

    private func serverErrors(in error: hGraphQL.GraphQLError?) -> [Apollo.GraphQLError]? {
        guard let error, case let .graphQLError(errors) = error else { return nil }
        return errors
    }

    // MARK: - AuthError

    @Test
    func logGraphQLExceptionRefreshFailedLogsError() async {
        do {
            let client = makeClient(.failure(AuthError.refreshFailed))

            await #expect(throws: hGraphQL.GraphQLError.self) {
                try await self.fetchCurrentMemberId(with: client)
            }

            #expect(logger.entries.map(\.level) == [.error])
            #expect(logger.entries.first?.message.contains("auth refresh failed") == true)
            #expect(logger.entries.first?.error == String(describing: AuthError.refreshFailed))
        }

        await restoreLoggerAndExpectClientReleased()
    }

    @Test
    func logGraphQLExceptionNetworkIssueLogsWarn() async {
        do {
            let client = makeClient(.failure(AuthError.networkIssue))

            await #expect(throws: hGraphQL.GraphQLError.self) {
                try await self.fetchCurrentMemberId(with: client)
            }

            #expect(logger.entries.map(\.level) == [.warn])
            #expect(logger.entries.first?.message.contains("network issue") == true)
        }

        await restoreLoggerAndExpectClientReleased()
    }

    @Test
    func logGraphQLExceptionRefreshTokenExpiredLogsNothing() async {
        do {
            let client = makeClient(.failure(AuthError.refreshTokenExpired))

            await #expect(throws: hGraphQL.GraphQLError.self) {
                try await self.fetchCurrentMemberId(with: client)
            }

            #expect(logger.entries.isEmpty, "an expired refresh token is a logout, not a failure to monitor")
        }

        await restoreLoggerAndExpectClientReleased()
    }

    // MARK: - Transport errors

    @Test
    func logGraphQLExceptionUnreachableNetworkLogsWarn() async {
        do {
            let client = makeClient(.failure(URLError(.notConnectedToInternet)))

            await #expect(throws: hGraphQL.GraphQLError.self) {
                try await self.fetchCurrentMemberId(with: client)
            }

            #expect(logger.entries.map(\.level) == [.warn])
            #expect(logger.entries.first?.message.contains("network issue") == true)
        }

        await restoreLoggerAndExpectClientReleased()
    }

    @Test(arguments: [URLError.Code.timedOut, .cannotConnectToHost, .secureConnectionFailed])
    func logGraphQLExceptionReachedTheServerLogsError(code: URLError.Code) async {
        do {
            let client = makeClient(.failure(URLError(code)))

            await #expect(throws: hGraphQL.GraphQLError.self) {
                try await self.fetchCurrentMemberId(with: client)
            }

            #expect(logger.entries.map(\.level) == [.error])
        }

        await restoreLoggerAndExpectClientReleased()
    }

    @Test
    func logGraphQLExceptionUnreachableNetworkOnMutationLogsWarn() async {
        do {
            let client = makeClient(.failure(URLError(.networkConnectionLost)))

            await #expect(throws: hGraphQL.GraphQLError.self) {
                try await self.requestMemberDeletion(with: client)
            }

            #expect(logger.entries.map(\.level) == [.warn])
        }

        await restoreLoggerAndExpectClientReleased()
    }

    // MARK: - Server side GraphQL errors

    @Test
    func logGraphQLExceptionServerErrorLogsTheServerMessage() async {
        do {
            let client = makeClient(.serverErrorMessages(["Member not found"]))

            let thrown = await #expect(throws: hGraphQL.GraphQLError.self) {
                try await self.fetchCurrentMemberId(with: client)
            }

            // One entry only, and still a .graphQLError: rethrowing it unlogged is what keeps the catch
            // from logging the same failure a second time and rewrapping it as .otherError.
            #expect(logger.entries.map(\.level) == [.error])
            #expect(logger.entries.first?.message.contains("Member not found") == true)
            #expect(logger.entries.first?.error == "Member not found")
            #expect(serverErrors(in: thrown)?.first?.message == "Member not found")
        }

        await restoreLoggerAndExpectClientReleased()
    }

    @Test
    func logGraphQLExceptionServerErrorsLogsEveryError() async {
        do {
            let client = makeClient(.serverErrorMessages(["first problem", "second problem"]))

            await #expect(throws: hGraphQL.GraphQLError.self) {
                try await self.fetchCurrentMemberId(with: client)
            }

            #expect(logger.entries.map(\.level) == [.error, .error])
            #expect(logger.entries.first?.message.contains("first problem") == true)
            #expect(logger.entries.last?.message.contains("second problem") == true)
        }

        await restoreLoggerAndExpectClientReleased()
    }

    // MARK: - Empty response

    @Test
    func logGraphQLExceptionEmptyFetchResponseLogsError() async {
        do {
            let client = makeClient(.emptyResponse)

            let thrown = await #expect(throws: hGraphQL.GraphQLError.self) {
                try await self.fetchCurrentMemberId(with: client)
            }

            #expect(logger.entries.map(\.level) == [.error])
            #expect(logger.entries.first?.message.contains("neither data nor errors") == true)
            #expect(serverErrors(in: thrown)?.isEmpty == true)
        }

        await restoreLoggerAndExpectClientReleased()
    }

    @Test
    func logGraphQLExceptionEmptyMutationResponseLogsNothing() async {
        await recordingErrors {
            let client = self.makeClient(.emptyResponse)

            let result = try await self.requestMemberDeletion(with: client)

            #expect(result == nil)
            #expect(self.logger.entries.isEmpty, "a mutation without a payload is not a failure")
        }

        await restoreLoggerAndExpectClientReleased()
    }
}

final class LoggerSpy: Logging {
    enum Level: Equatable {
        case debug
        case info
        case notice
        case warn
        case error
        case critical
    }

    struct Entry: Equatable {
        let level: Level
        let message: String
        let error: String?
    }

    private(set) var entries = [Entry]()

    private func record(_ level: Level, _ message: String, _ error: (any Error)?) {
        entries.append(Entry(level: level, message: message, error: error.map { String(describing: $0) }))
    }

    func debug(_ message: String, error: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record(.debug, message, error)
    }

    func info(_ message: String, error: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record(.info, message, error)
    }

    func notice(_ message: String, error: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record(.notice, message, error)
    }

    func warn(_ message: String, error: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record(.warn, message, error)
    }

    func error(_ message: String, error: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record(.error, message, error)
    }

    func critical(_ message: String, error: Error?, attributes _: [AttributeKey: AttributeValue]?) {
        record(.critical, message, error)
    }

    func addUserAction(
        type _: LoggingAction,
        name _: String,
        error _: Error?,
        attributes _: [AttributeKey: AttributeValue]?
    ) {}

    func addError(error _: Error, type _: ErrorSource, attributes _: [AttributeKey: AttributeValue]?) {}
}

// Replaces the request chain so a fetch can fail exactly the way a test needs it to, without a server.
final class StubNetworkTransport: NetworkTransport, @unchecked Sendable {
    enum Outcome {
        case failure(any Error)
        case serverErrorMessages([String])
        case emptyResponse
    }

    private let outcome: Outcome

    init(_ outcome: Outcome) {
        self.outcome = outcome
    }

    func send<Query: GraphQLQuery>(
        query _: Query,
        fetchBehavior _: FetchBehavior,
        requestConfiguration _: RequestConfiguration
    ) throws -> AsyncThrowingStream<GraphQLResponse<Query>, any Error> {
        responseStream()
    }

    func send<Mutation: GraphQLMutation>(
        mutation _: Mutation,
        requestConfiguration _: RequestConfiguration
    ) throws -> AsyncThrowingStream<GraphQLResponse<Mutation>, any Error> {
        responseStream()
    }

    // The response is built inside the stream so every value handed to `yield` is freshly created here.
    private func responseStream<Operation: GraphQLOperation>()
        -> AsyncThrowingStream<GraphQLResponse<Operation>, any Error>
    {
        switch outcome {
        case let .failure(error):
            return AsyncThrowingStream { continuation in
                continuation.finish(throwing: error)
            }

        case let .serverErrorMessages(messages):
            return AsyncThrowingStream { continuation in
                continuation.yield(
                    GraphQLResponse<Operation>(
                        data: nil,
                        extensions: nil,
                        errors: messages.map { Apollo.GraphQLError(["message": $0]) },
                        source: .server,
                        dependentKeys: nil
                    )
                )
                continuation.finish()
            }

        case .emptyResponse:
            return AsyncThrowingStream { continuation in
                continuation.yield(
                    GraphQLResponse<Operation>(
                        data: nil,
                        extensions: nil,
                        errors: nil,
                        source: .server,
                        dependentKeys: nil
                    )
                )
                continuation.finish()
            }
        }
    }
}
