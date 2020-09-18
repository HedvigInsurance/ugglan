import Foundation
import hCore
import hGraphQL

extension GraphQL.KeyGearItemQuery {
    convenience init(id: String) {
        self.init(id: id, languageCode: Localization.Locale.currentLocale.code)
    }
}
