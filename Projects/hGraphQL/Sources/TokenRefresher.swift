import Foundation
import Apollo
import Flow
import authlib

class TokenRefresher {
    static let shared = TokenRefresher()
    
    var isRefreshing: ReadWriteSignal<Bool> = ReadWriteSignal(false)
    
    var needRefresh: Bool {
        guard let token = ApolloClient.retreiveToken() else {
            return false
        }
        
        return Date().addingTimeInterval(60) > token.accessTokenExpirationDate
    }
    
    func refreshIfNeeded() -> Future<Void> {
        guard let token = ApolloClient.retreiveToken() else {
            return Future(result: .success)
        }
        
        return Future { completion in
            let bag = DisposeBag()
            
            guard self.needRefresh else {
                completion(.success)
                return bag
            }
            
            if self.isRefreshing.value {
                bag += self.isRefreshing.filter(predicate: { isRefreshing in
                    !isRefreshing
                }).onFirstValue({ _ in
                    completion(.success)
                })
            } else if Date() > token.refreshTokenExpirationDate {
                forceLogoutHook()
                completion(.failure(AuthError.refreshTokenExpired))
            } else {
                self.isRefreshing.value = true
                NetworkAuthRepository(
                    environment: Environment.current.authEnvironment,
                    additionalHttpHeaders: ApolloClient.headers()
                )
                .exchange(grant: RefreshTokenGrant(code: token.refreshToken)) { result, error in
                    if let successResult = result as? AuthTokenResultSuccess {
                        ApolloClient.handleAuthTokenSuccessResult(result: successResult)
                        self.isRefreshing.value = false
                        completion(.success)
                    } else {
                        forceLogoutHook()
                        completion(.failure(AuthError.refreshFailed))
                    }
                }
            }
            
            return bag
        }
    }
}
