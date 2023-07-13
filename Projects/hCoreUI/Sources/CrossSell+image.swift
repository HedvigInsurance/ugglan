import Foundation
import UIKit
import hGraphQL

extension CrossSell {
    public var image: UIImage {
        switch type {
        case .home: return HCoreUIAsset.bigPillowHome.image
        case .car: return HCoreUIAsset.bigPillowCar.image
        case .accident: return HCoreUIAsset.bigPillowAccident.image
        case .pet: return HCoreUIAsset.bigPillowPet.image
        case .unknown: return HCoreUIAsset.bigPillowHome.image
        }
    }
}
