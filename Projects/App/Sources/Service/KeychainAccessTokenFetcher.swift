import Apollo
import HedvigShared
import hGraphQL

public class IosAccessTokenFetcher: AccessTokenFetcher {
    public init() {}

    public func fetch() async throws -> String? {
        try await TokenRefresher.shared.refreshIfNeeded()
        return try await ApolloClient.retreiveToken()?.accessToken
    }
}
