import Apollo
import Flow
import Foundation
import authlib

public class TokenRefresher {
    public static let shared = TokenRefresher()
    var isRefreshing: ReadWriteSignal<Bool> = ReadWriteSignal(false)
    public var isDemoMode = false
    var needRefresh: Bool {
        guard let token = try? ApolloClient.retreiveToken() else {
            return false
        }

        return Date().addingTimeInterval(60) > token.accessTokenExpirationDate
    }

    public func refreshIfNeeded() async throws {
        let token = try ApolloClient.retreiveToken()
        guard let token = token else {
            if !isDemoMode {
                forceLogoutHook()
                log.info("Access token refresh missing token", error: nil, attributes: nil)
                throw AuthError.refreshTokenExpired
            }
            return
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
            let repository = NetworkAuthRepository(
                environment: Environment.current.authEnvironment,
                additionalHttpHeadersProvider: { ApolloClient.headers() },
                httpClientEngine: nil
            )
            let exchangeResult = try await repository.exchange(grant: RefreshTokenGrant(code: token.refreshToken))
            switch onEnum(of: exchangeResult) {
            case .success(let success):
                log.info("Refresh was sucessfull")
                ApolloClient.handleAuthTokenSuccessResult(result: success)
                self.isRefreshing.value = false
                return
            case .error(let error):
                log.error("Refreshing failed \(error.errorMessage), forcing logout")
                forceLogoutHook()
                throw AuthError.refreshFailed
            }
        }
    }
}

extension AuthTokenResultError {
    fileprivate var errorMessage: String {
        switch onEnum(of: self) {
        case .backendErrorResponse(let error): return error.message
        case .iOError(let ioError): return ioError.message
        case .unknownError(let unknownError): return unknownError.message
        }
    }
}
