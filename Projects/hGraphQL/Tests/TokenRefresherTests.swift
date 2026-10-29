import Foundation
import TestDependencies
import Testing

@testable import hGraphQL

@Suite(.serialized)
@MainActor
final class TokenRefresherTests {
    // Serialized because every test swaps the process-wide forceLogoutHook and restores it.
    private weak var sut: TokenRefresher?
    private var originalForceLogoutHook: (() -> Void)!
    private var forceLogoutCount = 0

    init() {
        originalForceLogoutHook = forceLogoutHook
        forceLogoutHook = { [weak self] in self?.forceLogoutCount += 1 }
    }

    // Bodies are scoped in do/recordingErrors so locals are released and throws still reach the restore.
    private func restoreHookAndExpectRefresherReleased() async {
        forceLogoutHook = originalForceLogoutHook
        originalForceLogoutHook = nil
        try? await Task.sleep(nanoseconds: 100)
        #expect(sut == nil, "the token refresher must not outlive the test that created it")
    }

    // MARK: - Single caller

    @Test
    func refreshIfNeededValidAccessTokenSkipsRefreshSuccess() async {
        await recordingErrors {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: 120, refreshExpiresIn: 3600))
            let refresher = mock.makeRefresher()
            sut = refresher

            try await refresher.refreshIfNeeded()

            #expect(mock.events == [.retrieveToken])
            #expect(forceLogoutCount == 0)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededMissingTokenFailure() async {
        do {
            let mock = MockTokenSource(token: nil)
            let refresher = mock.makeRefresher()
            sut = refresher

            await #expect(throws: AuthError.refreshTokenExpired) { try await refresher.refreshIfNeeded() }

            #expect(mock.events == [.retrieveToken])
            #expect(forceLogoutCount == 1)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededExpiredRefreshTokenFailure() async {
        do {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: -10, refreshExpiresIn: -1))
            let refresher = mock.makeRefresher()
            sut = refresher

            await #expect(throws: AuthError.refreshTokenExpired) { try await refresher.refreshIfNeeded() }

            #expect(mock.events == [.retrieveToken])
            #expect(forceLogoutCount == 1)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededExpiringAccessTokenRefreshesSuccess() async {
        await recordingErrors {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
            let refresher = mock.makeRefresher()
            sut = refresher

            try await refresher.refreshIfNeeded()

            #expect(mock.events == [.retrieveToken, .retrieveToken, .refresh(token: "refresh-token")])
            #expect(forceLogoutCount == 0)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededMissingOnRefreshFailure() async {
        do {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
            let refresher = mock.makeRefresher(withOnRefresh: false)
            sut = refresher

            await #expect(throws: AuthError.refreshFailed) { try await refresher.refreshIfNeeded() }

            #expect(mock.events == [.retrieveToken])
            #expect(forceLogoutCount == 0)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededNetworkIssueRethrowsWithoutLogoutFailure() async {
        await recordingErrors {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
            mock.refreshResult = { throw AuthError.networkIssue }
            let refresher = mock.makeRefresher()
            sut = refresher

            await #expect(throws: AuthError.networkIssue) { try await refresher.refreshIfNeeded() }
            #expect(forceLogoutCount == 0)

            // The failed in-flight task must be cleared so the next call starts a fresh refresh.
            mock.refreshResult = {}
            try await refresher.refreshIfNeeded()

            #expect(
                mock.events == [
                    .retrieveToken, .retrieveToken, .refresh(token: "refresh-token"),
                    .retrieveToken, .retrieveToken, .refresh(token: "refresh-token"),
                ]
            )
            #expect(forceLogoutCount == 0)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededNonAuthErrorRethrowsWithoutLogoutFailure() async {
        do {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
            mock.refreshResult = { throw URLError(.timedOut) }
            let refresher = mock.makeRefresher()
            sut = refresher

            let error = await #expect(throws: URLError.self) { try await refresher.refreshIfNeeded() }
            #expect(error?.code == .timedOut)
            #expect(forceLogoutCount == 0)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededSequentialCallsStartNewRefreshSuccess() async {
        await recordingErrors {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
            let refresher = mock.makeRefresher()
            sut = refresher

            try await refresher.refreshIfNeeded()
            try await refresher.refreshIfNeeded()

            #expect(mock.refreshCount == 2)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededTokenRotatedDuringReadSkipsRefreshSuccess() async {
        await recordingErrors {
            // The re-read inside the refresh task sees the rotated token, so the stale one must not be exchanged.
            let staleToken = OAuthorizationToken.mock(accessExpiresIn: 30, refreshExpiresIn: 3600, refreshToken: "old")
            let rotatedToken = OAuthorizationToken.mock(
                accessExpiresIn: 3600,
                refreshExpiresIn: 7200,
                refreshToken: "rotated"
            )
            let mock = MockTokenSource(token: rotatedToken)
            mock.queuedTokens = [staleToken]
            let refresher = mock.makeRefresher()
            sut = refresher

            try await refresher.refreshIfNeeded()

            #expect(mock.events == [.retrieveToken, .retrieveToken])
            #expect(mock.refreshCount == 0)
            #expect(forceLogoutCount == 0)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededTokenMissingOnReReadStillRefreshesSuccess() async {
        await recordingErrors {
            // Documents current behavior: only a *different* refresh token skips the refresh; a missing one does not.
            let mock = MockTokenSource(token: nil)
            mock.queuedTokens = [.mock(accessExpiresIn: 30, refreshExpiresIn: 3600)]
            let refresher = mock.makeRefresher()
            sut = refresher

            try await refresher.refreshIfNeeded()

            #expect(mock.events == [.retrieveToken, .retrieveToken, .refresh(token: "refresh-token")])
            #expect(forceLogoutCount == 0)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    // MARK: - Concurrency

    @Test
    func refreshIfNeededConcurrentCallsShareInFlightRefreshSuccess() async {
        do {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
            let refreshGate = AsyncGate()
            mock.refreshResult = { await refreshGate.wait() }
            let refresher = mock.makeRefresher()
            sut = refresher

            let tasks = startConcurrentCallers(on: refresher, count: 1)
            await yieldUntil { refreshGate.waiterCount == 1 }
            let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 3)

            refreshGate.open()
            let results = await collect(tasks + lateTasks)

            #expect(results.count == 4)
            #expect(results.allSatisfy { $0 == nil }, "Expected all callers to succeed, got \(results)")
            #expect(mock.refreshCount == 1)
            #expect(forceLogoutCount == 0)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededConcurrentCallsDuringTokenReadShareSingleRefreshSuccess() async {
        do {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
            let retrieveGate = AsyncGate()
            mock.retrieveGate = retrieveGate
            let refresher = mock.makeRefresher()
            sut = refresher

            // The first caller is still in the token read; the shared task wraps it, so the others must join it.
            let tasks = startConcurrentCallers(on: refresher, count: 1)
            await yieldUntil { retrieveGate.waiterCount == 1 }
            let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 3)

            retrieveGate.open()
            let results = await collect(tasks + lateTasks)

            #expect(results.allSatisfy { $0 == nil }, "Expected all callers to succeed, got \(results)")
            #expect(mock.refreshCount == 1)
            #expect(mock.events.filter { $0 == .retrieveToken }.count == 2)
            #expect(forceLogoutCount == 0)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededConcurrentCallsExpiredRefreshTokenLogOutOnceFailure() async {
        do {
            // A burst against a long-expired refresh token: every caller throws, but logout happens only once.
            let mock = MockTokenSource(token: .mock(accessExpiresIn: -10, refreshExpiresIn: -1))
            let retrieveGate = AsyncGate()
            mock.retrieveGate = retrieveGate
            let refresher = mock.makeRefresher()
            sut = refresher

            let tasks = startConcurrentCallers(on: refresher, count: 1)
            await yieldUntil { retrieveGate.waiterCount == 1 }
            let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 24)

            retrieveGate.open()
            let results = await collect(tasks + lateTasks)

            #expect(results.count == 25)
            #expect(
                results.allSatisfy { ($0 as? AuthError) == .refreshTokenExpired },
                "Expected all callers to throw .refreshTokenExpired, got \(results)"
            )
            #expect(mock.events == [.retrieveToken])
            #expect(forceLogoutCount == 1)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededConcurrentCallsMissingTokenLogOutOnceFailure() async {
        do {
            let mock = MockTokenSource(token: nil)
            let retrieveGate = AsyncGate()
            mock.retrieveGate = retrieveGate
            let refresher = mock.makeRefresher()
            sut = refresher

            let tasks = startConcurrentCallers(on: refresher, count: 1)
            await yieldUntil { retrieveGate.waiterCount == 1 }
            let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 24)

            retrieveGate.open()
            let results = await collect(tasks + lateTasks)

            #expect(
                results.allSatisfy { ($0 as? AuthError) == .refreshTokenExpired },
                "Expected all callers to throw .refreshTokenExpired, got \(results)"
            )
            #expect(mock.events == [.retrieveToken])
            #expect(forceLogoutCount == 1)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    // MARK: - Force logout latch

    @Test
    func refreshIfNeededLaterBurstsAfterLogoutStaySilentFailure() async {
        do {
            // The shared task collapses one burst; the latch collapses the waves that follow it.
            let mock = MockTokenSource(token: .mock(accessExpiresIn: -10, refreshExpiresIn: -1))
            let refresher = mock.makeRefresher()
            sut = refresher

            for _ in 0..<3 {
                await #expect(throws: AuthError.refreshTokenExpired) { try await refresher.refreshIfNeeded() }
            }

            #expect(forceLogoutCount == 1)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededLogsOutAgainAfterTokenWasStoredFailure() async {
        do {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: -10, refreshExpiresIn: -1))
            let refresher = mock.makeRefresher()
            sut = refresher

            await #expect(throws: AuthError.refreshTokenExpired) { try await refresher.refreshIfNeeded() }
            refresher.tokenWasStored()
            await #expect(throws: AuthError.refreshTokenExpired) { try await refresher.refreshIfNeeded() }

            #expect(forceLogoutCount == 2)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededConcurrentCallsPropagateRefreshFailedFailure() async {
        do {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
            let refreshGate = AsyncGate()
            mock.refreshResult = {
                await refreshGate.wait()
                throw AuthError.refreshFailed
            }
            let refresher = mock.makeRefresher()
            sut = refresher

            let tasks = startConcurrentCallers(on: refresher, count: 1)
            await yieldUntil { refreshGate.waiterCount == 1 }
            let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 4)

            refreshGate.open()
            let results = await collect(tasks + lateTasks)

            #expect(results.count == 5)
            #expect(
                results.allSatisfy { ($0 as? AuthError) == .refreshFailed },
                "Expected all callers to throw .refreshFailed, got \(results)"
            )
            #expect(mock.refreshCount == 1)
            #expect(forceLogoutCount == 1)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    @Test
    func refreshIfNeededConcurrentCallsPropagateNetworkIssueFailure() async {
        await recordingErrors {
            let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
            let refreshGate = AsyncGate()
            mock.refreshResult = {
                await refreshGate.wait()
                throw AuthError.networkIssue
            }
            let refresher = mock.makeRefresher()
            sut = refresher

            let tasks = startConcurrentCallers(on: refresher, count: 1)
            await yieldUntil { refreshGate.waiterCount == 1 }
            let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 3)

            refreshGate.open()
            let results = await collect(tasks + lateTasks)

            #expect(
                results.allSatisfy { ($0 as? AuthError) == .networkIssue },
                "Expected all callers to throw .networkIssue, got \(results)"
            )
            #expect(mock.refreshCount == 1)
            #expect(forceLogoutCount == 0)

            // Task is cleared after failure, so a later call starts a new refresh.
            mock.refreshResult = {}
            try await refresher.refreshIfNeeded()
            #expect(mock.refreshCount == 2)
        }

        await restoreHookAndExpectRefresherReleased()
    }

    // MARK: - Helpers

    private func startConcurrentCallers(
        on refresher: TokenRefresher,
        count: Int
    ) -> [Task<Error?, Never>] {
        (0..<count).map { _ in Task { await Self.capture { try await refresher.refreshIfNeeded() } } }
    }

    /// Starts callers mid-refresh; once every caller has bumped `counter`, each is awaiting the shared task.
    private func startCallersJoiningInFlightRefresh(
        on refresher: TokenRefresher,
        count: Int
    ) async -> [Task<Error?, Never>] {
        let counter = Counter()
        let tasks = (0..<count)
            .map { _ in
                Task { () -> Error? in
                    counter.value += 1
                    return await Self.capture { try await refresher.refreshIfNeeded() }
                }
            }
        await yieldUntil { counter.value == count }
        return tasks
    }

    private static func capture(_ block: () async throws -> Void) async -> Error? {
        do {
            try await block()
            return nil
        } catch {
            return error
        }
    }

    private func collect(_ tasks: [Task<Error?, Never>]) async -> [Error?] {
        var results = [Error?]()
        for task in tasks { results.append(await task.value) }
        return results
    }

    private func yieldUntil(
        maxYields: Int = 10_000,
        sourceLocation: SourceLocation = #_sourceLocation,
        _ condition: () -> Bool
    ) async {
        for _ in 0..<maxYields {
            if condition() { return }
            await Task.yield()
        }
        Issue.record("Condition not met after \(maxYields) yields", sourceLocation: sourceLocation)
    }
}

@MainActor
final class MockTokenSource {
    enum Event: Equatable {
        case retrieveToken
        case refresh(token: String)
    }

    var events = [Event]()
    var token: OAuthorizationToken?
    /// Returned (in order) by the next reads before falling back to `token`.
    var queuedTokens = [OAuthorizationToken?]()
    var retrieveGate: AsyncGate?
    var refreshResult: () async throws -> Void = {}
    private(set) var retrieveReturnedCount = 0

    var refreshCount: Int {
        events.filter { if case .refresh = $0 { return true } else { return false } }.count
    }

    init(token: OAuthorizationToken?) {
        self.token = token
    }

    func makeRefresher(withOnRefresh: Bool = true) -> TokenRefresher {
        let refresher = TokenRefresher(retrieveToken: { [weak self] in
            guard let self else { return nil }
            return await self.retrieveToken()
        })
        if withOnRefresh {
            refresher.onRefresh = { [weak self] refreshToken in
                try await self?.refresh(refreshToken: refreshToken)
            }
        }
        return refresher
    }

    private func retrieveToken() async -> OAuthorizationToken? {
        events.append(.retrieveToken)
        await retrieveGate?.wait()
        retrieveReturnedCount += 1
        return queuedTokens.isEmpty ? token : queuedTokens.removeFirst()
    }

    private func refresh(refreshToken: String) async throws {
        events.append(.refresh(token: refreshToken))
        try await refreshResult()
    }
}

@MainActor
final class AsyncGate {
    private var continuations = [CheckedContinuation<Void, Never>]()
    private var isOpen = false
    private(set) var waiterCount = 0

    func wait() async {
        if isOpen { return }
        waiterCount += 1
        await withCheckedContinuation { continuations.append($0) }
    }

    func open() {
        isOpen = true
        continuations.forEach { $0.resume() }
        continuations.removeAll()
    }
}

@MainActor
final class Counter {
    var value = 0
}

extension OAuthorizationToken {
    static func mock(
        accessExpiresIn: TimeInterval,
        refreshExpiresIn: TimeInterval,
        refreshToken: String = "refresh-token"
    ) -> OAuthorizationToken {
        OAuthorizationToken(
            accessToken: "access-token",
            accessTokenExpirationDate: Date().addingTimeInterval(accessExpiresIn),
            refreshToken: refreshToken,
            refreshTokenExpirationDate: Date().addingTimeInterval(refreshExpiresIn)
        )
    }
}
