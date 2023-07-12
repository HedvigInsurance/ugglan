import Foundation
import UIKit
import hGraphQL

extension CrossSell {
    public var image: UIImage {
        if typeOfContract.contains("HOME") {
            return HCoreUIAsset.bigPillowHome.image
        } else if typeOfContract.contains("PET") {
            return HCoreUIAsset.bigPillowPet.image
        } else if typeOfContract.contains("CAR") {
            return HCoreUIAsset.bigPillowCar.image
        } else if typeOfContract.contains("ACCIDENT") {
            return HCoreUIAsset.bigPillowAccident.image
        } else {
            return HCoreUIAsset.bigPillowHome.image
        }
    }
}
