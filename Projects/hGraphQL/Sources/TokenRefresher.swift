import Apollo
import Combine
import Foundation

@MainActor
public class TokenRefresher {
    public static let shared = TokenRefresher()
    private var isRefreshing: CurrentValueSubject<Bool, Never> = CurrentValueSubject<Bool, Never>(false)
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
            log.info("Access token refresh missing token", error: nil, attributes: nil)
            throw AuthError.refreshTokenExpired
        }

        log.debug("Checking if access token refresh is needed")
        guard await self.needRefresh() else {
            log.debug("Access token refresh is not needed")
            return
        }

        if self.isRefreshing.value {
            log.debug("Already refreshing waiting until that is complete")
            var returnedValue = false
            try await withCheckedThrowingContinuation {
                [weak self] (inCont: CheckedContinuation<Void, Error>) -> Void in
                guard let self = self else { return }
                self.isRefreshing.first(where: { !$0 })
                    .sink { value in
                        log.debug("Refresh completed")
                        if !returnedValue {
                            returnedValue = true
                            inCont.resume()
                        }
                    }
                    .store(in: &self.cancellables)
            }
            return
        } else if Date() > token.refreshTokenExpirationDate {
            log.info("Refresh token expired at \(token.refreshTokenExpirationDate) forcing logout")
            forceLogoutHook()
            throw AuthError.refreshTokenExpired
        } else {
            self.isRefreshing.send(true)
            log.info("Will start refreshing token")

            do {
                try await onRefresh?(token.refreshToken)
                self.isRefreshing.send(false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.cancellables.removeAll()
                }
            } catch let error {
                log.error("Refreshing failed \(error.localizedDescription), forcing logout")
                forceLogoutHook()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.cancellables.removeAll()
                }
                throw error
            }
        }
    }

    public var onRefresh: ((_ token: String) async throws -> Void)?
}
