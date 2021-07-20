import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

class AddressState {
    var query: GraphQL.AddressAutocompleteQuery {
            GraphQL.QuoteBundleQuery(ids: ids, locale: Localization.Locale.currentLocale.asGraphQLLocale())
        }
}
