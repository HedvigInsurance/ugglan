import Foundation
import UIKit
import hCore
import hGraphQL

extension PillowType {
    public var bgImage: UIImage {
        switch self {
        case .accident:
            return hCoreUIAssets.bigPillowAccident.image
        case .car:
            return hCoreUIAssets.bigPillowCar.image
        case .cat:
            return hCoreUIAssets.bigPillowCat.image
        case .dog:
            return hCoreUIAssets.bigPillowDog.image
        case .home:
            return hCoreUIAssets.bigPillowHome.image
        case .homeOwner:
            return hCoreUIAssets.bigPillowHomeowner.image
        case .pet:
            return hCoreUIAssets.bigPillowPet.image
        case .rental:
            return hCoreUIAssets.bigPillowRental.image
        case .student:
            return hCoreUIAssets.bigPillowStudent.image
        case .travel:
            return hCoreUIAssets.bigPillowHome.image
        case .villa:
            return hCoreUIAssets.bigPillowVilla.image
        case .unknown:
            return hCoreUIAssets.bigPillowHome.image
        }
    }
}
