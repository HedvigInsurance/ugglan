@preconcurrency import Apollo
import HedvigShared

class KeychainAccessTokenFetcher : AccessTokenFetcher {
    func fetch() -> String? {
        final class TokenBox: @unchecked Sendable {
            var token: String?
        }

        let semaphore = DispatchSemaphore(value: 0)
        let box = TokenBox()
        Task {
            do {
                box.token = try await ApolloClient.retreiveToken()?.accessToken
            } catch {
                box.token = nil
            }
            semaphore.signal()
        }
        semaphore.wait()
        return box.token
    }
}
