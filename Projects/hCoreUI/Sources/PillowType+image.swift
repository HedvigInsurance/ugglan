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

    public var name: String {
        switch self {
        case .accident:
            return hCoreUIAssets.bigPillowAccident.name
        case .car:
            return hCoreUIAssets.bigPillowCar.name
        case .cat:
            return hCoreUIAssets.bigPillowCat.name
        case .dog:
            return hCoreUIAssets.bigPillowDog.name
        case .home:
            return hCoreUIAssets.bigPillowHome.name
        case .homeOwner:
            return hCoreUIAssets.bigPillowHomeowner.name
        case .pet:
            return hCoreUIAssets.bigPillowPet.name
        case .rental:
            return hCoreUIAssets.bigPillowRental.name
        case .student:
            return hCoreUIAssets.bigPillowStudent.name
        case .travel:
            return hCoreUIAssets.bigPillowHome.name
        case .villa:
            return hCoreUIAssets.bigPillowVilla.name
        case .unknown:
            return hCoreUIAssets.bigPillowHome.name
        }
    }
}

extension String {
    public var getPillowType: PillowType {
        switch self {
        case "big.pillow.accident":
            return .accident
        case "big.pillow.car":
            return .car
        case "big.pillow.cat":
            return .cat
        case "big.pillow.dog":
            return .dog
        case "big.pillow.home":
            return .home
        case "big.pillow.homeOwner":
            return .homeOwner
        case "big.pillow.pet":
            return .pet
        case "big.pillow.rental":
            return .rental
        case "big.pillow.student":
            return .student
        case "big.pillow.travel":
            return .travel
        case "big.pillow.villa":
            return .villa
        default:
            return .home
        }
    }
}
