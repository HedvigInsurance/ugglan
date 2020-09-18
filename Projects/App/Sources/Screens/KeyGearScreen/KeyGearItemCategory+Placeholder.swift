import Foundation
import hGraphQL
import UIKit

extension GraphQL.KeyGearItemCategory {
    var image: UIImage? {
        switch self {
        case .phone:
            return Asset.keyGearPhonePlaceholder.image
        case .smartWatch, .watch:
            return Asset.keyGearWatchPlacholder.image
        case .tablet:
            return Asset.keyGearTabletPlaceholder.image
        case .__unknown:
            return nil
        default:
            return nil
        }
    }
}
