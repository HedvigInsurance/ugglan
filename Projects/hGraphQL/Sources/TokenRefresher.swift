import Apollo
import Foundation

@MainActor
public class TokenRefresher {
    public static let shared = TokenRefresher()
    public var onRefresh: ((_ token: String) async throws -> Void)?
    private let retrieveToken: () async throws -> OAuthorizationToken?
    /// In-flight work shared by all concurrent callers, so they all get the same result (including failures)
    private var refreshTask: Task<Void, Error>?
    private var hasForcedLogout = false

    init(retrieveToken: @escaping () async throws -> OAuthorizationToken? = { try await ApolloClient.retreiveToken() })
    {
        self.retrieveToken = retrieveToken
    }

    func tokenWasStored() {
        hasForcedLogout = false
    }

    public func refreshIfNeeded() async throws {
        if let refreshTask {
            graphQlLogger.debug("Already refreshing, awaiting result")
            return try await refreshTask.value
        }

        // Nothing suspends between the check above and the assignment below, and this is the main
        // actor, so every caller that arrives while the body runs joins it instead of repeating it.
        // That has to cover the whole body, not just the exchange: the expired-refresh-token branch
        // never reaches an exchange, and it is the one that fires on every request in a burst.
        let task = Task { try await self.refresh() }
        refreshTask = task
        defer { refreshTask = nil }
        try await task.value
    }

    private func refresh() async throws {
        guard let token = try await retrieveToken() else {
            forceLogout {
                graphQlLogger.info("Access token refresh missing token", error: nil, attributes: nil)
            }
            throw AuthError.refreshTokenExpired
        }

        graphQlLogger.debug("Checking if access token refresh is needed")
        guard Date().addingTimeInterval(60) > token.accessTokenExpirationDate else {
            graphQlLogger.debug("Access token refresh is not needed")
            return
        }

        guard Date() < token.refreshTokenExpirationDate else {
            forceLogout {
                graphQlLogger.info("Refresh token expired at \(token.refreshTokenExpirationDate) forcing logout")
            }
            throw AuthError.refreshTokenExpired
        }

        guard let onRefresh else {
            graphQlLogger.error("Access token refresh requested before onRefresh was configured")
            throw AuthError.refreshFailed
        }

        // A refresh that completed while we were reading the keychain has already rotated the
        // refresh token; exchanging the stale one would fail and force a logout.
        if let current = try await retrieveToken(), current.refreshToken != token.refreshToken {
            graphQlLogger.debug("Access token was already refreshed")
            return
        }

        graphQlLogger.info("Will start refreshing token")
        do {
            try await onRefresh(token.refreshToken)
        } catch {
            switch error {
            case AuthError.refreshTokenExpired, AuthError.refreshFailed:
                forceLogout {
                    graphQlLogger.error(
                        "Refreshing failed \(String(describing: error)), forcing logout",
                        error: error,
                        attributes: nil
                    )
                }
            case AuthError.networkIssue:
                graphQlLogger.info("Refreshing token postponed, network unavailable")
            default:
                graphQlLogger.error(
                    "Refreshing failed \(String(describing: error))",
                    error: error,
                    attributes: nil
                )
            }
            throw error
        }
    }

    // The shared task already collapses one burst. This collapses the whole logged-in session:
    // once the member is on their way out, later waves of requests find no token and would
    // otherwise announce the logout again. ApolloClient.saveToken re-arms it on the next login.
    private func forceLogout(_ logReason: () -> Void) {
        guard !hasForcedLogout else { return }
        hasForcedLogout = true
        logReason()
        forceLogoutHook()
    }
}
