import Foundation
import SwiftUI
import hCore
import hGraphQL

extension PillowType {
    public var bgImage: UIImage {
        asset.image
    }

    private var asset: ImageAsset {
        switch self {
        case .accident:
            return hCoreUIAssets.bigPillowAccident
        case .car:
            return hCoreUIAssets.bigPillowCar
        case .cat:
            return hCoreUIAssets.bigPillowCat
        case .dog:
            return hCoreUIAssets.bigPillowDog
        case .home:
            return hCoreUIAssets.bigPillowHome
        case .homeOwner:
            return hCoreUIAssets.bigPillowHomeowner
        case .pet:
            return hCoreUIAssets.bigPillowPet
        case .rental:
            return hCoreUIAssets.bigPillowRental
        case .student:
            return hCoreUIAssets.bigPillowStudent
        case .travel:
            return hCoreUIAssets.bigPillowHome
        case .villa:
            return hCoreUIAssets.bigPillowVilla
        case .unknown:
            return hCoreUIAssets.bigPillowHome
        }
    }
}
