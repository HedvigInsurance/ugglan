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
                cachePolicy: .fetchIgnoringCacheData
            )
            .map { data in
                data.activeContractBundles.map { ActiveContractBundle(bundle: $0) }
            }
    }

    public func fetchContracts(locale: GraphQL.Locale) -> Future<[Contract]> {
        return
            self.fetch(
                query: GraphQL.ContractsQuery(
                    locale: locale
                ),
                cachePolicy: .fetchIgnoringCacheData
            )
            .map { $0.contracts }
            .map { $0.compactMap { Contract(contract: $0) } }
    }

    public func fetchUpcomingContracts(locale: GraphQL.Locale) -> Future<[UpcomingAgreementContract]> {
        return
            self.fetch(
                query: GraphQL.UpcomingAgreementQuery(
                    locale: locale
                ),
                cachePolicy: .fetchIgnoringCacheData
            )
            .map { $0.contracts }
            .map { $0.map { UpcomingAgreementContract(contract: $0) } }
    }
}
