import Foundation
import UIKit
import hGraphQL

extension CrossSell {
    public var image: UIImage {
        if typeOfContract.contains("HOME") {
            return HCoreUIAsset.pillowHome.image
        } else if typeOfContract.contains("PET") {
            return HCoreUIAsset.pillowPet.image
        } else if typeOfContract.contains("CAR") {
            return HCoreUIAsset.pillowCar.image
        } else if typeOfContract.contains("ACCIDENT") {
            return HCoreUIAsset.pillowAccident.image
        } else {
            return HCoreUIAsset.pillowHome.image
        }
    }
}
