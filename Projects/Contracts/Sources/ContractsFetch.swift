import Apollo
import Flow
import Foundation
import hGraphQL

extension ApolloClient {
    public func fetchActiveContractBundles(locale: GiraffeGraphQL.Locale) -> Future<[ActiveContractBundle]> {
        return
            self.fetch(
                query: GiraffeGraphQL.ActiveContractBundlesQuery(
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

    public func fetchContracts(locale: GiraffeGraphQL.Locale) -> Future<[Contract]> {
        return
            self.fetch(
                query: GiraffeGraphQL.ContractsQuery(
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
