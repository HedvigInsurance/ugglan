import Foundation
import hCore
import hGraphQL

extension GraphQL.KeyGearItemCategory {
  var name: String {
    switch self {
    case .computer: return L10n.itemTypeComputer
    case .phone: return L10n.itemTypePhone
    case .tv: return L10n.itemTypeTv
    case .jewelry: return L10n.itemTypeJewelry
    case .bike: return L10n.itemTypeBike
    case .watch: return L10n.itemTypeWatch
    case .smartWatch: return L10n.itemTypeSmartWatch
    case .tablet: return L10n.itemTypeTablet
    case .__unknown: return ""
    }
  }
}
