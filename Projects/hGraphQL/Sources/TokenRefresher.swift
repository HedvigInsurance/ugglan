import Apollo
import Combine
import Foundation

@MainActor
public class TokenRefresher {
    public static let shared = TokenRefresher()
    private var isRefreshing: CurrentValueSubject<Bool, Never> = .init(false)
    private var cancellables = Set<AnyCancellable>()
    private func needRefresh() async -> Bool {
        guard let token = try? await ApolloClient.retreiveToken() else {
            return false
        }
        return Date().addingTimeInterval(60) > token.accessTokenExpirationDate
    }

    public func refreshIfNeeded() async throws {
        let token = try await ApolloClient.retreiveToken()
        guard let token = token else {
            forceLogoutHook()
            graphQlLogger.info("Access token refresh missing token", error: nil, attributes: nil)
            throw AuthError.refreshTokenExpired
        }

        graphQlLogger.debug("Checking if access token refresh is needed")
        guard await needRefresh() else {
            graphQlLogger.debug("Access token refresh is not needed")
            return
        }

        if isRefreshing.value {
            graphQlLogger.debug("Already refreshing waiting until that is complete")
            var returnedValue = false
            try await withCheckedThrowingContinuation {
                [weak self] (inCont: CheckedContinuation<Void, Error>) in
                guard let self = self else { return }
                self.isRefreshing.first(where: { !$0 })
                    .sink { _ in
                        graphQlLogger.debug("Refresh completed")
                        if !returnedValue {
                            returnedValue = true
                            inCont.resume()
                        }
                    }
                    .store(in: &self.cancellables)
            }
            return
        } else if Date() > token.refreshTokenExpirationDate {
            graphQlLogger.info("Refresh token expired at \(token.refreshTokenExpirationDate) forcing logout")
            forceLogoutHook()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.cancellables.removeAll()
            }
            throw AuthError.refreshTokenExpired
        } else {
            isRefreshing.send(true)
            graphQlLogger.info("Will start refreshing token")

            do {
                try await onRefresh?(token.refreshToken)
                isRefreshing.send(false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.cancellables.removeAll()
                }
            } catch {
                graphQlLogger.error("Refreshing failed \(error.localizedDescription), forcing logout")
                if let error = error as? AuthError {
                    switch error {
                    case .refreshTokenExpired, .refreshFailed:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            self?.cancellables.removeAll()
                        }
                        forceLogoutHook()
                    case .networkIssue:
                        break
                    }
                }
                isRefreshing.send(false)
                throw error
            }
        }
    }

    public var onRefresh: ((_ token: String) async throws -> Void)?
}
