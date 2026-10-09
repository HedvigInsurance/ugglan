@preconcurrency import XCTest

@testable import hGraphQL

@MainActor
final class TokenRefresherTests: XCTestCase {
    weak var sut: TokenRefresher?
    private var originalForceLogoutHook: (() -> Void)!
    private var forceLogoutCount = 0

    override func setUp() async throws {
        try await super.setUp()
        originalForceLogoutHook = forceLogoutHook
        forceLogoutCount = 0
        forceLogoutHook = { [weak self] in self?.forceLogoutCount += 1 }
    }

    override func tearDown() async throws {
        forceLogoutHook = originalForceLogoutHook
        originalForceLogoutHook = nil
        try await Task.sleep(nanoseconds: 100)
        XCTAssertNil(sut)
    }

    // MARK: - Single caller

    func testRefreshIfNeededValidAccessTokenSkipsRefreshSuccess() async throws {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: 120, refreshExpiresIn: 3600))
        let refresher = mock.makeRefresher()
        sut = refresher

        try await refresher.refreshIfNeeded()

        XCTAssertEqual(mock.events, [.retrieveToken])
        XCTAssertEqual(forceLogoutCount, 0)
    }

    func testRefreshIfNeededMissingTokenFailure() async {
        let mock = MockTokenSource(token: nil)
        let refresher = mock.makeRefresher()
        sut = refresher

        await assertThrows(.refreshTokenExpired) { try await refresher.refreshIfNeeded() }

        XCTAssertEqual(mock.events, [.retrieveToken])
        XCTAssertEqual(forceLogoutCount, 1)
    }

    func testRefreshIfNeededExpiredRefreshTokenFailure() async {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: -10, refreshExpiresIn: -1))
        let refresher = mock.makeRefresher()
        sut = refresher

        await assertThrows(.refreshTokenExpired) { try await refresher.refreshIfNeeded() }

        XCTAssertEqual(mock.events, [.retrieveToken])
        XCTAssertEqual(forceLogoutCount, 1)
    }

    func testRefreshIfNeededExpiringAccessTokenRefreshesSuccess() async throws {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
        let refresher = mock.makeRefresher()
        sut = refresher

        try await refresher.refreshIfNeeded()

        XCTAssertEqual(mock.events, [.retrieveToken, .retrieveToken, .refresh(token: "refresh-token")])
        XCTAssertEqual(forceLogoutCount, 0)
    }

    func testRefreshIfNeededMissingOnRefreshFailure() async {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
        let refresher = mock.makeRefresher(withOnRefresh: false)
        sut = refresher

        await assertThrows(.refreshFailed) { try await refresher.refreshIfNeeded() }

        XCTAssertEqual(mock.events, [.retrieveToken])
        XCTAssertEqual(forceLogoutCount, 0)
    }

    func testRefreshIfNeededNetworkIssueRethrowsWithoutLogoutFailure() async throws {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
        mock.refreshResult = { throw AuthError.networkIssue }
        let refresher = mock.makeRefresher()
        sut = refresher

        await assertThrows(.networkIssue) { try await refresher.refreshIfNeeded() }
        XCTAssertEqual(forceLogoutCount, 0)

        // The failed in-flight task must be cleared so the next call starts a fresh refresh.
        mock.refreshResult = {}
        try await refresher.refreshIfNeeded()

        XCTAssertEqual(
            mock.events,
            [
                .retrieveToken, .retrieveToken, .refresh(token: "refresh-token"),
                .retrieveToken, .retrieveToken, .refresh(token: "refresh-token"),
            ]
        )
        XCTAssertEqual(forceLogoutCount, 0)
    }

    func testRefreshIfNeededNonAuthErrorRethrowsWithoutLogoutFailure() async {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
        mock.refreshResult = { throw URLError(.timedOut) }
        let refresher = mock.makeRefresher()
        sut = refresher

        do {
            try await refresher.refreshIfNeeded()
            XCTFail("Expected URLError to be thrown")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .timedOut)
        }
        XCTAssertEqual(forceLogoutCount, 0)
    }

    func testRefreshIfNeededSequentialCallsStartNewRefreshSuccess() async throws {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
        let refresher = mock.makeRefresher()
        sut = refresher

        try await refresher.refreshIfNeeded()
        try await refresher.refreshIfNeeded()

        XCTAssertEqual(mock.refreshCount, 2)
    }

    func testRefreshIfNeededTokenRotatedDuringReadSkipsRefreshSuccess() async throws {
        // First read returns a stale token (another refresh completed meanwhile); the re-read inside the
        // refresh task sees the rotated refresh token, so the stale one must not be exchanged.
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

        XCTAssertEqual(mock.events, [.retrieveToken, .retrieveToken])
        XCTAssertEqual(mock.refreshCount, 0)
        XCTAssertEqual(forceLogoutCount, 0)
    }

    func testRefreshIfNeededTokenMissingOnReReadStillRefreshesSuccess() async throws {
        // Documents current behavior: only a *different* refresh token skips the refresh; a missing one does not.
        let mock = MockTokenSource(token: nil)
        mock.queuedTokens = [.mock(accessExpiresIn: 30, refreshExpiresIn: 3600)]
        let refresher = mock.makeRefresher()
        sut = refresher

        try await refresher.refreshIfNeeded()

        XCTAssertEqual(mock.events, [.retrieveToken, .retrieveToken, .refresh(token: "refresh-token")])
        XCTAssertEqual(forceLogoutCount, 0)
    }

    // MARK: - Concurrency

    func testRefreshIfNeededConcurrentCallsShareInFlightRefreshSuccess() async throws {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
        let refreshGate = AsyncGate()
        mock.refreshResult = { await refreshGate.wait() }
        let refresher = mock.makeRefresher()
        sut = refresher

        let tasks = startConcurrentCallers(on: refresher, count: 1)
        await waitUntil { refreshGate.waiterCount == 1 }
        let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 3)

        refreshGate.open()
        let results = await collect(tasks + lateTasks)

        XCTAssertEqual(results.count, 4)
        XCTAssertTrue(results.allSatisfy { $0 == nil }, "Expected all callers to succeed, got \(results)")
        XCTAssertEqual(mock.refreshCount, 1)
        XCTAssertEqual(forceLogoutCount, 0)
    }

    func testRefreshIfNeededConcurrentCallsDuringTokenReadShareSingleRefreshSuccess() async throws {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
        let retrieveGate = AsyncGate()
        mock.retrieveGate = retrieveGate
        let refresher = mock.makeRefresher()
        sut = refresher

        // The first caller is still inside the token read. Because the shared task wraps the read
        // too, the others must join it rather than start a read of their own.
        let tasks = startConcurrentCallers(on: refresher, count: 1)
        await waitUntil { retrieveGate.waiterCount == 1 }
        let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 3)

        retrieveGate.open()
        let results = await collect(tasks + lateTasks)

        XCTAssertTrue(results.allSatisfy { $0 == nil }, "Expected all callers to succeed, got \(results)")
        XCTAssertEqual(mock.refreshCount, 1)
        XCTAssertEqual(mock.events.filter { $0 == .retrieveToken }.count, 2)
        XCTAssertEqual(forceLogoutCount, 0)
    }

    func testRefreshIfNeededConcurrentCallsExpiredRefreshTokenLogOutOnceFailure() async throws {
        // The prod case: a burst of in-flight requests against a refresh token that expired weeks
        // ago. Every caller has to throw, but the member is only logged out once.
        let mock = MockTokenSource(token: .mock(accessExpiresIn: -10, refreshExpiresIn: -1))
        let retrieveGate = AsyncGate()
        mock.retrieveGate = retrieveGate
        let refresher = mock.makeRefresher()
        sut = refresher

        let tasks = startConcurrentCallers(on: refresher, count: 1)
        await waitUntil { retrieveGate.waiterCount == 1 }
        let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 24)

        retrieveGate.open()
        let results = await collect(tasks + lateTasks)

        XCTAssertEqual(results.count, 25)
        XCTAssertTrue(
            results.allSatisfy { ($0 as? AuthError) == .refreshTokenExpired },
            "Expected all callers to throw .refreshTokenExpired, got \(results)"
        )
        XCTAssertEqual(mock.events, [.retrieveToken])
        XCTAssertEqual(forceLogoutCount, 1)
    }

    func testRefreshIfNeededConcurrentCallsMissingTokenLogOutOnceFailure() async throws {
        let mock = MockTokenSource(token: nil)
        let retrieveGate = AsyncGate()
        mock.retrieveGate = retrieveGate
        let refresher = mock.makeRefresher()
        sut = refresher

        let tasks = startConcurrentCallers(on: refresher, count: 1)
        await waitUntil { retrieveGate.waiterCount == 1 }
        let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 24)

        retrieveGate.open()
        let results = await collect(tasks + lateTasks)

        XCTAssertTrue(
            results.allSatisfy { ($0 as? AuthError) == .refreshTokenExpired },
            "Expected all callers to throw .refreshTokenExpired, got \(results)"
        )
        XCTAssertEqual(mock.events, [.retrieveToken])
        XCTAssertEqual(forceLogoutCount, 1)
    }

    // MARK: - Force logout latch

    func testRefreshIfNeededLaterBurstsAfterLogoutStaySilentFailure() async {
        // The shared task collapses one burst; the latch collapses the waves that follow it.
        let mock = MockTokenSource(token: .mock(accessExpiresIn: -10, refreshExpiresIn: -1))
        let refresher = mock.makeRefresher()
        sut = refresher

        for _ in 0..<3 {
            await assertThrows(.refreshTokenExpired) { try await refresher.refreshIfNeeded() }
        }

        XCTAssertEqual(forceLogoutCount, 1)
    }

    func testRefreshIfNeededLogsOutAgainAfterTokenWasStoredFailure() async {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: -10, refreshExpiresIn: -1))
        let refresher = mock.makeRefresher()
        sut = refresher

        await assertThrows(.refreshTokenExpired) { try await refresher.refreshIfNeeded() }
        refresher.tokenWasStored()
        await assertThrows(.refreshTokenExpired) { try await refresher.refreshIfNeeded() }

        XCTAssertEqual(forceLogoutCount, 2)
    }

    func testRefreshIfNeededConcurrentCallsPropagateRefreshFailedFailure() async throws {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
        let refreshGate = AsyncGate()
        mock.refreshResult = {
            await refreshGate.wait()
            throw AuthError.refreshFailed
        }
        let refresher = mock.makeRefresher()
        sut = refresher

        let tasks = startConcurrentCallers(on: refresher, count: 1)
        await waitUntil { refreshGate.waiterCount == 1 }
        let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 4)

        refreshGate.open()
        let results = await collect(tasks + lateTasks)

        XCTAssertEqual(results.count, 5)
        XCTAssertTrue(
            results.allSatisfy { ($0 as? AuthError) == .refreshFailed },
            "Expected all callers to throw .refreshFailed, got \(results)"
        )
        XCTAssertEqual(mock.refreshCount, 1)
        XCTAssertEqual(forceLogoutCount, 1)
    }

    func testRefreshIfNeededConcurrentCallsPropagateNetworkIssueFailure() async throws {
        let mock = MockTokenSource(token: .mock(accessExpiresIn: 30, refreshExpiresIn: 3600))
        let refreshGate = AsyncGate()
        mock.refreshResult = {
            await refreshGate.wait()
            throw AuthError.networkIssue
        }
        let refresher = mock.makeRefresher()
        sut = refresher

        let tasks = startConcurrentCallers(on: refresher, count: 1)
        await waitUntil { refreshGate.waiterCount == 1 }
        let lateTasks = await startCallersJoiningInFlightRefresh(on: refresher, count: 3)

        refreshGate.open()
        let results = await collect(tasks + lateTasks)

        XCTAssertTrue(
            results.allSatisfy { ($0 as? AuthError) == .networkIssue },
            "Expected all callers to throw .networkIssue, got \(results)"
        )
        XCTAssertEqual(mock.refreshCount, 1)
        XCTAssertEqual(forceLogoutCount, 0)

        // Task is cleared after failure, so a later call starts a new refresh.
        mock.refreshResult = {}
        try await refresher.refreshIfNeeded()
        XCTAssertEqual(mock.refreshCount, 2)
    }

    // MARK: - Helpers

    private func startConcurrentCallers(
        on refresher: TokenRefresher,
        count: Int
    ) -> [Task<Error?, Never>] {
        (0..<count).map { _ in Task { await Self.capture { try await refresher.refreshIfNeeded() } } }
    }

    /// Starts callers while a refresh is in flight. Each task increments `started` synchronously right before
    /// calling `refreshIfNeeded()` on the main actor, so once `started == count` every caller has passed the first
    /// `refreshTask` check and is awaiting the shared task.
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
        await waitUntil { counter.value == count }
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

    private func waitUntil(
        maxYields: Int = 10_000,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ condition: () -> Bool
    ) async {
        for _ in 0..<maxYields {
            if condition() { return }
            await Task.yield()
        }
        XCTFail("Condition not met after \(maxYields) yields", file: file, line: line)
    }

    private func assertThrows(
        _ expected: AuthError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ block: () async throws -> Void
    ) async {
        do {
            try await block()
            XCTFail("Expected \(expected) to be thrown", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? AuthError, expected, file: file, line: line)
        }
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
