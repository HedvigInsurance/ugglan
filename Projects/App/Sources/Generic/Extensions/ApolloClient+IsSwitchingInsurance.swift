import Apollo
import Contracts
import Flow
import Foundation
import hCore
import hGraphQL

extension ApolloClient {
    var isSwitchingInsurance: Future<Bool> {
        fetch(
            query: GiraffeGraphQL.ContractsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()),
            cachePolicy: .fetchIgnoringCacheData
        )
        .map { data -> Bool in
            data.contracts.contains { contract -> Bool in contract.switchedFromInsuranceProvider != nil }
        }
    }
}
