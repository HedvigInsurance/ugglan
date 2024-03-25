import Apollo
import Flow
import Foundation

public class TokenRefresher {
    public static let shared = TokenRefresher()
    var isRefreshing: ReadWriteSignal<Bool> = ReadWriteSignal(false)
    var needRefresh: Bool {
        guard let token = try? ApolloClient.retreiveToken() else {
            return false
        }

        return Date().addingTimeInterval(60) > token.accessTokenExpirationDate
    }

    public func refreshIfNeeded() async throws {
        let token = try ApolloClient.retreiveToken()
        guard let token = token else {
            forceLogoutHook()
            log.info("Access token refresh missing token", error: nil, attributes: nil)
            throw AuthError.refreshTokenExpired
        }

        log.debug("Checking if access token refresh is needed")
        guard self.needRefresh else {
            log.debug("Access token refresh is not needed")
            return
        }

        if self.isRefreshing.value {
            log.debug("Already refreshing waiting until that is complete")
            try await withCheckedThrowingContinuation { (inCont: CheckedContinuation<Void, Error>) -> Void in
                let bag = DisposeBag()
                bag += self.isRefreshing
                    .filter(predicate: { isRefreshing in
                        !isRefreshing
                    })
                    .onFirstValue({ _ in
                        log.debug("Refresh completed")
                        inCont.resume()
                    })
            }
            return
        } else if Date() > token.refreshTokenExpirationDate {
            log.info("Refresh token expired at \(token.refreshTokenExpirationDate) forcing logout")
            forceLogoutHook()
            throw AuthError.refreshTokenExpired
        } else {
            self.isRefreshing.value = true
            log.info("Will start refreshing token")

            do {
                try await onRefresh?(token.refreshToken)
                self.isRefreshing.value = false
            } catch let error {
                log.error("Refreshing failed \(error.localizedDescription), forcing logout")
                forceLogoutHook()
                throw error
            }
        }
    }

    public var onRefresh: ((_ token: String) async throws -> Void)?
}
