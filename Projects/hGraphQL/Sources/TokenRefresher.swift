import Foundation
import Apollo
import Flow
import authlib

public class TokenRefresher {
    public static let shared = TokenRefresher()
    
    var isRefreshing: ReadWriteSignal<Bool> = ReadWriteSignal(false)
    
    var needRefresh: Bool {
        guard let token = ApolloClient.retreiveToken() else {
            return false
        }
        
        return Date().addingTimeInterval(60) > token.accessTokenExpirationDate
    }
    
    public func refreshIfNeeded() -> Future<Void> {
        guard let token = ApolloClient.retreiveToken() else {
            return Future(result: .success)
        }
        
        return Future { completion in
            let bag = DisposeBag()
            
            log.info("Checking if access token refresh is needed")
                        
            guard self.needRefresh else {
                log.info("Access token refresh is not needed")
                completion(.success)
                return bag
            }
            
            if self.isRefreshing.value {
                log.info("Already refreshing waiting until that is complete")
                
                bag += self.isRefreshing.filter(predicate: { isRefreshing in
                    !isRefreshing
                }).onFirstValue({ _ in
                    log.info("Refresh completed")
                    completion(.success)
                })
            } else if Date() > token.refreshTokenExpirationDate {
                log.info("Refresh token expired at \(token.refreshTokenExpirationDate) forcing logout")
                forceLogoutHook()
                completion(.failure(AuthError.refreshTokenExpired))
            } else {
                self.isRefreshing.value = true
                log.info("Will start refreshing token")
                NetworkAuthRepository(
                    environment: Environment.current.authEnvironment,
                    additionalHttpHeaders: ApolloClient.headers()
                )
                .exchange(grant: RefreshTokenGrant(code: token.refreshToken)) { result, error in
                    if let successResult = result as? AuthTokenResultSuccess {
                        log.info("Refresh was sucessfull")

                        ApolloClient.handleAuthTokenSuccessResult(result: successResult)
                        self.isRefreshing.value = false
                        completion(.success)
                    } else {
                        log.error(
                            "Refreshing failed \(String(describing: result)), forcing logout",
                            error: error
                        )
                        forceLogoutHook()
                        completion(.failure(AuthError.refreshFailed))
                    }
                }
            }
            
            return bag
        }
    }
}
