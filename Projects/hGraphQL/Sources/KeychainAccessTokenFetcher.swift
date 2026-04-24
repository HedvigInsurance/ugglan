import Apollo
import HedvigShared

public class IosAccessTokenFetcher: AccessTokenFetcher {
    public init() {}

    public func fetch() async throws -> String? {
        try await ApolloClient.retreiveToken()?.accessToken
    }
}
