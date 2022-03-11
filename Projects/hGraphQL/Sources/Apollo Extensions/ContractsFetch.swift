import Apollo
import Flow
import Foundation

extension ApolloClient {
    public func fetchActiveContractBundles(locale: GraphQL.Locale) -> Future<[ActiveContractBundle]> {
        return
            self.fetch(
                query: GraphQL.ActiveContractBundlesQuery(
                    locale: locale
                ),
                cachePolicy: .fetchIgnoringCacheData,
                queue: .global(qos: .background)
            )
            .map(on: .background) { data in
                data.activeContractBundles.map { ActiveContractBundle(bundle: $0) }
            }
            .map(on: .main) { $0 }
    }

    public func fetchContracts(locale: GraphQL.Locale) -> Future<[Contract]> {
        return
            self.fetch(
                query: GraphQL.ContractsQuery(
                    locale: locale
                ),
                cachePolicy: .fetchIgnoringCacheData,
                queue: .global(qos: .background)
            )
            .map(on: .background) { $0.contracts }
            .map(on: .background) { $0.compactMap { Contract(contract: $0) } }
            .map(on: .main) { $0 }
    }
}
